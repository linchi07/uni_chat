import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uni_chat/main.dart';

/// 文件工具类，提供保存文本和图片的方法
class FileUtils {
  /// 保存文本内容到指定文件
  /// [text] 要保存的文本内容
  /// [fileName] 文件名（包含扩展名）
  /// 返回保存的文件路径，如果保存失败则返回null
  static Future<String?> saveTextToFile(String text, String fileName) async {
    try {
      // 打开系统保存对话框
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: '请选择保存位置',
        fileName: fileName,
      );

      // 如果用户选择了保存位置
      if (outputPath != null) {
        // 创建文件并写入文本内容
        File file = File(outputPath);
        await file.writeAsString(text);
        return outputPath;
      }

      return null;
    } catch (e) {
      // 发生异常时返回null
      return null;
    }
  }

  /// 保存Base64编码的图片到文件
  /// [base64String] Base64编码的字符串
  /// [mimeType] MIME类型，如 image/png, image/jpeg 等
  /// [fileName] 文件名（包含扩展名）
  /// 返回保存的文件路径，如果保存失败则返回null
  static Future<String?> saveBase64ImageToFile(
    String base64String,
    String mimeType,
    String fileName,
  ) async {
    try {
      // 打开系统保存对话框
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: '请选择保存位置',
        fileName: fileName,
      );

      // 如果用户选择了保存位置
      if (outputPath != null) {
        // 解码Base64字符串
        // 如果Base64字符串包含data URI前缀，则移除前缀
        if (base64String.startsWith('data:')) {
          base64String = base64String.split(',').last;
        }

        Uint8List imageBytes = base64Decode(base64String);

        // 创建文件并写入图片数据
        File file = File(outputPath);
        await file.writeAsBytes(imageBytes);
        return outputPath;
      }

      return null;
    } catch (e) {
      // 发生异常时返回null
      return null;
    }
  }
}

class PathProvider {
  static Future<String> getPath(String relativePath) async {
    relativePath = "/$relativePath";
    if (PlatForm().platform == Platform.windows) {
      // windows真的烦，还得给他擦屁股
      relativePath = relativePath.replaceAll(RegExp(r'/'), r'\');
    }
    var finalPath =
        "${(await getApplicationDocumentsDirectory()).path}$relativePath";
    var dir = Directory(p.dirname(finalPath));
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }
    return finalPath;
  }
}
