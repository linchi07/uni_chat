import 'dart:async';
import 'dart:typed_data';

import 'package:super_native_extensions/raw_clipboard.dart' as raw;
import 'package:uni_chat/main.dart';

import 'models.dart';
import 'resolver.dart';

class NativeClipboard {
  /// 读取剪切板内容
  static Future<NativeDataReader?> read({
    Set<FileFormat>? supportedFormats,
  }) async {
    final reader = await raw.ClipboardReader.instance.newClipboardReader();

    // 获取 Items (raw.DataReaderItem)
    final items = await reader.getItems();

    // 解析
    final resolvedItems = await NativeTypeResolver.resolveItems(
      items,
      supportedFormats,
    );

    return NativeDataReader(resolvedItems);
  }

  /// 写入剪切板
  static Future<void> write(List<NativeDataWriterItem> items) async {
    final providers = <raw.DataProviderHandle>[];

    for (var item in items) {
      final representations = <raw.DataRepresentation>[];

      // 处理文本
      for (var text in item._texts) {
        if (PlatForm().platform == RunningPlatform.ios ||
            PlatForm().platform == RunningPlatform.macos ||
            PlatForm().platform == RunningPlatform.ipadOS) {
          representations.add(
            raw.DataRepresentation.simple(
              format: "public.utf8-plain-text", // Mac/iOS
              data: text,
            ),
          );
        }else if(PlatForm().isWindows){
          representations.add(
            raw.DataRepresentation.simple(
              format: "NativeShell_CF_13", // Windows
              data: text,
            ),
          );
        }else{
          representations.add(
          raw.DataRepresentation.simple(
            format: "text/plain", // Web/Android
            data: text,
          ),
        );
        }
      }

      // 处理文件/二进制
      for (var fileData in item._files) {
        representations.add(
          raw.DataRepresentation.simple(
            format: fileData.format,
            data: fileData.data,
          ),
        );
      }

      final provider = raw.DataProvider(
        representations: representations,
        suggestedName: item.suggestedName,
      );
      final handle = await provider.register();
      providers.add(handle);
    }

    await raw.ClipboardWriter.instance.write(providers);
  }
}

/// 写入项封装
class NativeDataWriterItem {
  String? suggestedName;
  final List<String> _texts = [];
  final List<({String format, Uint8List data})> _files = [];

  /// 添加文本内容 (会自动映射为纯文本)
  void addText(String text) {
    _texts.add(text);
  }

  /// 添加二进制数据或文件
  /// [format] 建议传入 mime-type 或系统特定标识符
  void addData(Uint8List data, {required String format}) {
    _files.add((format: format, data: data));
  }
}
