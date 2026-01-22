import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Color, Offset;

import 'package:charset/charset.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:super_native_extensions/raw_clipboard.dart' as raw;
import 'package:super_native_extensions/raw_drag_drop.dart' show DropOperation;
import 'package:uni_chat/main.dart';

import 'file_semantic_map.g.dart';

export 'package:super_native_extensions/raw_drag_drop.dart' show DropOperation;

/// 拖放会话信息
class NativeDropSession {
  final List<NativeDropItem> items;
  final List<DropOperation> allowedOperations;

  NativeDropSession({required this.items, required this.allowedOperations});
}

class NativeDropItem {
  final List<String> formats;
  final Object? localData;

  NativeDropItem({required this.formats, this.localData});

  bool canProvide(String format) => formats.contains(format);
}

/// 拖放进入事件
class NativeDropEnterEvent {
  final NativeDropSession session;
  NativeDropEnterEvent({required this.session});
}

/// 拖放悬停事件
class NativeDropOverEvent {
  final Offset location;
  final NativeDropSession session;

  NativeDropOverEvent({required this.location, required this.session});
}

/// 拖放离开事件
class NativeDropLeaveEvent {
  final int sessionId;

  NativeDropLeaveEvent({required this.sessionId});
}

class AllowPlainText extends FileFormat {
  const AllowPlainText() : super(mimeType: "text/plain", extension: "allPlain");
}

class AllowAllTextFileFormats extends FileFormat {
  const AllowAllTextFileFormats() : super(mimeType: null, extension: "allText");
}

class AllowAllFileFormats extends FileFormat {
  const AllowAllFileFormats() : super(mimeType: null, extension: "*");
}

/// 自定义文件格式描述
class FileFormat {
  final String? mimeType;
  final String extension;

  /// the Extension should **NOT** contain dots
  const FileFormat({this.mimeType, required this.extension});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileFormat &&
          runtimeType == other.runtimeType &&
          extension == other.extension;

  @override
  int get hashCode => extension.hashCode;

  @override
  String toString() => "FileFormat(ext: $extension, mime: $mimeType)";
}

/// 统一的数据读取器
class NativeDataReader {
  final List<NativeData> _items;

  NativeDataReader(this._items);

  List<NativeData> get items => _items;

  /// 获取指定格式的数据
  List<NativeData> getData({Set<FileFormat>? only}) {
    if (only == null) return _items;
    return _items.where((item) => only.contains(item.format)).toList();
  }
}

/// 数据基类
abstract class NativeData {
  final String? name;
  final FileFormat format;
  final String? path;
  final raw.DataReaderItem _item;
  final raw.DataReaderItemInfo _info;

  NativeData({
    this.name,
    required this.format,
    this.path,
    required raw.DataReaderItem item,
    required raw.DataReaderItemInfo info,
  }) : _item = item,
       _info = info;

  /// 获取数据流 (内部使用，自动处理虚拟文件与合成文件)
  Stream<Uint8List> _openDataStream() async* {
    final virtualReceiver = _info.virtualReceivers.firstWhereOrNull(
      (r) =>
          r.format == _getPlatformFormat() || _info.formats.contains(r.format),
    );
    if (virtualReceiver != null) {
      final (futureFile, _) = virtualReceiver.receiveVirtualFile();
      final virtualFile = await futureFile.timeout(
        // to avoid a known issue
        // when dragging files from vscode based editors the rust layer will throw : (this seems to be a vscode issue since idea works perfectly (praise JetBrains))
        // Canceling drag because exception 'NSInternalInconsistencyException' (reason 'Could not get filename from URL:') was raised during a dragging session。
        // however the rust layer will not return an error , resulting a completer to wait forever

        // according to gemini (since I'm nuts to rust):
        // 1. 为什么会发生这种情况？（包的失误）
        // 在rust/src/darwin/macos/reader.rs 的第 498 行：
        // receiver.receivePromisedFilesAtDestination_options_operationQueue_reader(
        //     &url,
        //     &NSDictionary::dictionary(),
        //     &queue,
        //     &block, // 系统操作成功或失败后会调用这个回调
        // );
        // 这个方法是异步的。它接收一个 block 作为完成后的回调。在 Rust 层，它通过 FutureCompleter 等待这个 block 被执行。
        // 但是，如果 receivePromisedFiles... 这个调用本身在发起阶段就因为某些原因（比如你遇到的 VSCode 提供的数据不规范）抛出了 Objective-C 异常：
        // 程序流中断：Rust 代码在 498 行之后的部分（包括返回 future 的代码）可能根本没跑完，或者系统接管了异常。
        // 回调丢失：因为系统底层报错了，它根本没有进入异步拷贝阶段，所以它永远不会去调用你传进去的那个 block。
        // 死等：Rust 的 await 在等 completer.complete()，而 completer 在 block 里。block 不执行，Rust 的 await 就不返回。Dart 端的 MethodChannel 也就永远等不到回复。

        // the timeout is to force cancel the drag behaviour to prevent flutter from being jammed
        const Duration(seconds: 4),
        onTimeout: () async {
          var dir = Directory.systemTemp;
          await for (var f in dir.list()) {
            var e = p.basename(f.path);
            if (e.startsWith("vfr-")) {
              await f.delete();
            }
          }
          throw TimeoutException("Drag operation timed out");
        },
      );

      try {
        while (true) {
          final chunk = await virtualFile.readNext();
          if (chunk.isEmpty) break;
          yield chunk;
        }
      } catch (e) {
        virtualFile.close();
        rethrow;
      } finally {
        virtualFile.close();
      }
      return;
    }

    String targetFormat = _getPlatformFormat();
    if (!_info.formats.contains(targetFormat)) {
      // 如果 application/octet-stream 不在列表中，尝试寻找其他合理格式
      if (_info.formats.contains("public.utf8-plain-text")) {
        targetFormat = "public.utf8-plain-text";
      } else if (_info.formats.contains("text/plain")) {
        targetFormat = "text/plain";
      } else if (_info.formats.isNotEmpty) {
        targetFormat = _info.formats.first;
      }
    }

    final (future, _) = _item.getDataForFormat(targetFormat);
    final data = await future;

    if (data is Uint8List) {
      yield data;
    } else if (data is String) {
      yield utf8.encode(data);
    }
  }

  /// 尝试解析本地文件路径 (针对 public.file-url)
  Future<String?> _resolveFilePath() async {
    String? uriFormat;
    if(PlatForm().isWindows){
      if(_info.formats.contains("NativeShell_CF_15")) uriFormat = "NativeShell_CF_15";
    }else{
      if (_info.formats.contains("public.file-url")) {
        uriFormat = "public.file-url";
      } else if (_info.formats.contains("text/uri-list")) {
        uriFormat = "text/uri-list";
      }
    }


    if (uriFormat != null) {
      final (future, _) = _item.getDataForFormat(uriFormat);
      final data = await future;
      String? uriStr;
      if (data is String) {
        uriStr = data
            .split('\r\n')
            .firstWhere((l) => l.trim().isNotEmpty, orElse: () => data);
      } else if (data is Uint8List) {
        final s = utf8.decode(data, allowMalformed: true);
        uriStr = s
            .split('\r\n')
            .firstWhere((l) => l.trim().isNotEmpty, orElse: () => s);
      }

      if (uriStr != null) {
        Uri? uri;
        try {
          uri = Uri.tryParse(uriStr.trim());
        } catch (_) {}

        if (uri != null) {
          bool isFileUri = false;
          // 严谨校验
          if(PlatForm().isWindows){
            if (uri.isScheme('file')) {
              isFileUri = true;
            } else if (uriFormat == "NativeShell_CF_15") {
              uri = Uri.file(p.normalize(uriStr.trim()),windows: true);
                isFileUri = true;
              }
          }else {
            if (uri.isScheme('file')) {
              isFileUri = true;
            } else if (!uri.hasScheme &&
                (uri.path.startsWith('/') ||
                    uri.path.startsWith(RegExp(r'[a-zA-Z]:\\')))) {
              if (uriFormat == "public.file-url" ||
                  uriFormat == "text/uri-list") {
                uri = Uri.file(uriStr.trim());
                isFileUri = true;
              }
            }
          }
          if (isFileUri) {
            return uri.toFilePath();
          }
        }
      }
    }
    return null;
  }

  String _getPlatformFormat() {
    return format.mimeType ?? "application/octet-stream";
  }

  /// 将数据保存为本地文件
  Future<File> copyTo(
    String pathToDir, {
    String? rename,
    bool replaceIfExist = false,
    bool createDirIfNotExist = true,
    String? extension,
  }) async {
    if (createDirIfNotExist) {
      await Directory(pathToDir).create(recursive: true);
    }
    final fileName = rename ?? name ?? "unnamed_file";
    final ext = extension ?? format.extension;
    final fullPath = p.join(pathToDir, "$fileName.$ext");

    final file = File(fullPath);
    if (!replaceIfExist && await file.exists()) {
      throw FileSystemException("File already exists", fullPath);
    }

    // 优化：尝试直接复制本地文件
    final sourcePath = await _resolveFilePath();
    if (sourcePath != null) {
      await File(sourcePath).copy(fullPath);
      return file;
    }

    // 否则：写入流 (Virtual File)
    final ios = file.openWrite();
    await for (final chunk in _openDataStream()) {
      ios.add(chunk);
    }
    await ios.close();
    return file;
  }
}

/// 图像类
class NativeImage extends NativeData {
  NativeImage({
    required super.format,
    required super.item,
    required super.info,
    super.name,
    super.path,
  });
}

/// 纯文本类
class NativeText extends NativeData {
  NativeText({
    required super.format,
    required super.item,
    required super.info,
    super.name,
    super.path,
  });

  Future<String> getText() async {
    final formats = _info.formats;
    String? target;
    if(PlatForm().isWindows){
      if (formats.contains("NativeShell_CF_13")) {
        target = "NativeShell_CF_13";
      }
    }else{
      if (formats.contains("public.utf8-plain-text")) {
        target = "public.utf8-plain-text";
      } else if (formats.contains("text/plain")) {
        target = "text/plain";
      }
    }


    if (target != null) {
      final (future, _) = _item.getDataForFormat(target);
      final data = await future;
      if(PlatForm().isWindows){
        //windows uses utf16le codec
        return Utf16Decoder().decodeUtf16Le(data as List<int>);
      }
      if (data is String) return data;
      if (data is Uint8List) return utf8.decode(data);
    }

    // 兜底使用内部流
    final bytes = await _openDataStream().fold<List<int>>(
      [],
      (p, e) => p..addAll(e),
    );
    return utf8.decode(bytes);
  }

  NativeTextFile toNativeTextFile() => NativeTextFile(
    format: format,
    item: _item,
    info: _info,
    name: name,
    path: path,
  );
}

/// 文本文件类 (txt)
class NativeTextFile extends NativeData {
  final Color? color;

  NativeTextFile({
    required super.format,
    required super.item,
    required super.info,
    super.name,
    super.path,
    this.color,
  });

  factory NativeTextFile.fromLanguage(
    raw.DataReaderItem item,
    Language language,
    String name,
    String extension,
    raw.DataReaderItemInfo info,
  ) {
    return NativeTextFile(
      name: name,
      format: FileFormat(extension: extension, mimeType: language.mime),
      item: item,
      info: info,
      color: language.color,
    );
  }
}

class NativeFile extends NativeData {
  NativeFile({
    required super.format,
    required super.item,
    required super.info,
    super.name,
    super.path,
  });
}

class NativeVideo extends NativeData {
  NativeVideo({
    required super.format,
    required super.item,
    required super.info,
    super.name,
    super.path,
  });
}

class NativeAudio extends NativeData {
  NativeAudio({
    required super.format,
    required super.item,
    required super.info,
    super.name,
    super.path,
  });
}

enum Type {
  code, // programming + markup
  data, //data
  document, //prose
}

class Language {
  final Type type;
  final String name;
  final int? _colorCode;
  final String? mime;

  Color get color => Color(_colorCode ?? 0x00000000);

  static Language? getLanguage(String extension) {
    if (extension.startsWith('.')) {
      extension = extension.substring(1);
    }
    var id = EXT_INDEX[extension.trim()];
    return id != null ? LANGUAGES[id] : null;
  }

  const Language({
    required this.name,
    int? colorCode,
    required this.type,
    this.mime,
  }) : _colorCode = colorCode;
}
