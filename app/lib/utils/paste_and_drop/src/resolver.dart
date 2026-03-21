import 'package:path/path.dart' as p;
import 'package:super_native_extensions/raw_clipboard.dart' as raw;
import 'package:uni_chat/main.dart';
import 'package:uni_chat/utils/file_utils.dart';

import 'models.dart';

// win的剪贴板不允许阻塞也就是直接打断点，只能这样用一个不await的future来防止系统阻塞，这个只是debug用的
class TempStorage {
  static Future<void> writeA(List<String> a) async {
    await Future.delayed(const Duration(seconds: 4));
    print(a);
    return;
  }
}

class NativeTypeResolver {
  /// 智能解析数据项
  static Future<List<NativeData>> resolveItems(
    Iterable<raw.DataReaderItem> items,
    Set<FileFormat>? allowedFormats,
  ) async {
    final result = <NativeData>[];
    bool acceptAll = false;
    if (allowedFormats == null ||
        allowedFormats.contains(const AllowAllFileFormats())) {
      acceptAll = true;
    }
    // 使用 public static method 获取 info
    final infos = await raw.DataReaderItem.getItemInfo(items);

    int index = 0;
    for (final info in infos) {
      final item = items.elementAt(index++);

      if (info.synthesizedFromURIFormat?.contains("folder") ?? false) {
        continue;
        //  TODO: 暂不支持
      }

      final formats = info.formats.toSet();
      //TempStorage.writeA(formats.toList());
      late bool isFile;
      late bool hasText;
      if (PlatForm().isWindows) {
        isFile = formats.contains("NativeShell_CF_15");
        hasText = formats.contains("NativeShell_CF_13");
      } else {
        isFile = formats.contains("public.file-url");
        hasText =
            formats.contains("text/plain") ||
            formats.contains("public.utf8-plain-text");
      }
      var name = info.suggestedName;
      if (hasText && !isFile && name == null) {
        if (acceptAll || allowedFormats!.contains(const AllowPlainText())) ;
        result.add(
          NativeText(
            format: FileFormat(mimeType: "text/plain", extension: "txt"),
            item: item,
            info: info,
            name: info.suggestedName,
          ),
        );
        continue;
      }
      if (PlatForm().platform == RunningPlatform.ios &&
          name != null &&
          p.extension(name).isEmpty) {
        for (final format in info.formats) {
          final ext = PathProvider.iosCommonExtensions[format];
          if (ext != null) {
            name = "$name$ext";
            break;
          }
        }
      }

      if (name != null) {
        var ext = p.extension(name).toLowerCase();
        String extNoDot;
        if (ext.length >= 2) {
          extNoDot = ext.substring(1); //  去掉 .
        } else {
          extNoDot = ext;
        }
        if (ext.contains("png") ||
            ext.contains("jpg") ||
            ext.contains("jpeg") &&
                (acceptAll ||
                    allowedFormats!.contains(
                      FileFormat(extension: extNoDot),
                    ))) {
          result.add(
            NativeImage(
              format: FileFormat(
                mimeType: "image/$extNoDot",
                extension: extNoDot,
              ),
              item: item,
              info: info,
              name: name,
            ),
          );
          continue;
        }
        var r = Language.getLanguage(ext);
        if (r != null) {
          if (acceptAll ||
              allowedFormats!.contains(const AllowAllTextFileFormats()) ||
              allowedFormats.contains(FileFormat(extension: extNoDot))) {
            result.add(
              NativeTextFile.fromLanguage(item, r, name, extNoDot, info),
            );
          }
          continue;
        } else if (hasText && ext == "txt") {
          if (acceptAll ||
              allowedFormats!.contains(const AllowAllTextFileFormats()) ||
              allowedFormats.contains(const FileFormat(extension: "txt"))) {
            result.add(
              NativeTextFile(
                format: FileFormat(
                  mimeType: "text/plain",
                  extension: p.extension(name),
                ),
                item: item,
                info: info,
                name: name,
              ),
            );
          }
          continue;
        }
      } else if (formats.any(
            (f) =>
                f.startsWith("image/") ||
                f == "public.png" ||
                f == "public.jpeg",
          ) &&
          (acceptAll ||
              allowedFormats!.contains(const FileFormat(extension: "png")))) {
        String? mime = formats.firstWhere(
          (f) => f.startsWith("image/"),
          orElse: () => "image/png",
        );
        result.add(
          NativeImage(
            format: FileFormat(mimeType: mime, extension: "png"),
            item: item,
            info: info,
            name: info.suggestedName,
          ),
        );
        continue;
      }

      if (isFile) {
        var ext = p.extension(name ?? "");
        if (ext.startsWith(".")) {
          ext = ext.substring(1);
        }
        if (acceptAll || allowedFormats!.contains(FileFormat(extension: ext))) {
          result.add(
            NativeFile(
              format: FileFormat(
                mimeType: "application/octet-stream",
                extension: ext,
              ),
              item: item,
              info: info,
              name: name,
            ),
          );
        }
      } else if (hasText) {
        if (acceptAll ||
            allowedFormats!.contains(const AllowAllTextFileFormats()) ||
            allowedFormats.contains(FileFormat(extension: "txt"))) {
          // 如果没有 file-url 但有 text，即使可能是个文件内容，也作为 Text 处理
          result.add(
            NativeText(
              format: FileFormat(mimeType: "text/plain", extension: "txt"),
              item: item,
              info: info,
              name: name,
            ),
          );
        }
      }
    }

    return result;
  }
}
