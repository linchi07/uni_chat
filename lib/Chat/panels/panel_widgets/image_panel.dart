import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/src/consumer.dart';
import 'package:http/http.dart' as http;
import 'package:uni_chat/Chat/panels/basic_pannel.dart';
import 'package:uni_chat/Chat/panels/panel_data.dart';
import 'package:uni_chat/llm_provider/image_gen.dart';
import 'package:uni_chat/utils/file_utils.dart';

import '../../../generated/l10n.dart';
import '../../../utils/images.dart';

class ImagePanel extends BasicPanel {
  ImagePanel({super.key, required super.name});
  @override
  (String, List<Base64Image>?) panelSummary(PanelData data) {
    var image = data.props['imageBase64'];
    var mime = data.props['mimeType'];
    var s = image != null && mime != null
        ? "面板当前正在展示图片"
        : "面板当前没有图片，你可以要求用户上传图片，或者执行从url获取图片，亦或运行图片生成器。";
    if (image == null || mime == null) {
      return (s, null);
    }
    return (s, [Base64Image(base64Image: image, mimeType: mime)]);
  }

  @override
  Widget buildInternal(BuildContext context, WidgetRef ref, PanelData data) {
    return _ImagePanelContent(
      key: ValueKey("$name|1145141919810"),
      name: name,
      data: data,
    );
  }
}

class _ImagePanelContent extends ConsumerStatefulWidget {
  final String name;
  final PanelData data;

  const _ImagePanelContent({
    required this.name,
    required this.data,
    required Key key,
  }) : super(key: key);

  @override
  ConsumerState<_ImagePanelContent> createState() => _ImagePanelContentState();
}

class _ImagePanelContentState extends ConsumerState<_ImagePanelContent> {
  void generateImage(Map<String, String> params) async {
    if (params['prompt'] == null) {
      return;
    }
    if (_loading) {
      return;
    }
    try {
      var sd = ref.read(imageGenProvider);
      if (sd == null) {
        setState(() {
          _loading = false;
          _errorMessage = "请先设置图片生成模型";
        });
      }
      setState(() {
        _loading = true;
      });
      var image = await sd!.imageCreation(params['prompt']!, null);
      widget.data.props['imageBase64'] = image;
      setState(() {
        _loading = false;
        _imageBytes = base64Decode(image);
        _errorMessage = null;
      });
      widget.data.props['mimeType'] = _detectImageType(_imageBytes!);
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = e.toString();
      });
      print(e);
    }
  }

  void editImage(Map<String, String> params) async {
    print(widget.data.props['imageBase64']);
    if (params['prompt'] == null ||
        widget.data.props['imageBase64'] == null ||
        _loading) {
      return;
    }
    try {
      var sd = ref.read(imageGenProvider);
      if (sd == null) {
        setState(() {
          _loading = false;
          _errorMessage = "请先设置图片生成模型";
        });
      }
      setState(() {
        _loading = true;
      });
      var image = await sd!.image2imageGeneration(
        params['prompt']!,
        widget.data.props['imageBase64']!,
      );
      setState(() {
        _loading = false;
        _imageBytes = base64Decode(image);
        widget.data.props['imageBase64'] = image;
        widget.data.props['mimeType'] = _detectImageType(_imageBytes!);
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = e.toString();
      });
      print(e);
    }
  }

  String _detectImageType(Uint8List bytes) {
    if (bytes.length < 4) return 'image/png';

    // JPEG 文件头: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'image/jpeg';
    }

    // PNG 文件头: 89 50 4E 47
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }

    // GIF 文件头: 47 49 46
    if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
      return 'image/gif';
    }

    throw 'Unknown image format';
  }

  Uint8List? _imageBytes;
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      // 检查是否有Base64编码的图片数据
      final base64Image = widget.data.props['imageBase64'];
      if (base64Image != null && base64Image.isNotEmpty) {
        // 处理Base64数据，移除可能的数据URI前缀
        String base64String = base64Image;
        if (base64String.startsWith('data:')) {
          base64String = base64String.split(',').last;
        }
        Uint8List bytes = base64Decode(base64String);
        widget.data.props['mimeType'] = _detectImageType(bytes);
        setState(() {
          _imageBytes = bytes;
          _loading = false;
        });
        return;
      }

      // 检查是否有图片URL
      final imageUrl = widget.data.props['imageUrl'];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          setState(() {
            _imageBytes = response.bodyBytes;
            _loading = false;
          });
          widget.data.props['fileName'] = imageUrl.split('/').last;
          widget.data.props['imageBase64'] = base64Encode(response.bodyBytes);
          widget.data.props['mimeType'] = _detectImageType(response.bodyBytes);
        } else {
          throw Exception('Failed to load image from URL');
        }
        return;
      }

      // 没有提供图片数据
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        Uint8List bytes = await file.readAsBytes();

        setState(() {
          _imageBytes = bytes;
          _errorMessage = null;
        });

        // 将图片数据保存到PanelData中
        widget.data.props['mimeType'] = _detectImageType(bytes);
        String base64Image = base64Encode(bytes);
        widget.data.props['imageBase64'] = base64Image;
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _saveImage() async {
    if (_imageBytes == null) return;

    try {
      String? mimeType = 'image/png'; // 默认MIME类型
      String? fileName = 'image.png'; // 默认文件名

      // 尝试从PanelData中获取MIME类型和文件名
      final mimeTypeFromData = widget.data.props['mimeType'];
      final fileNameFromData = widget.data.props['fileName'];

      if (mimeTypeFromData != null) mimeType = mimeTypeFromData;
      if (fileNameFromData != null) fileName = fileNameFromData;

      await FileUtils.saveBase64ImageToFile(
        base64Encode(_imageBytes!),
        mimeType,
        fileName,
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.data.functions['generateImage'] = generateImage;
    widget.data.functions['editImage'] = editImage;
    return LayoutBuilder(
      builder: (context, constraints) {
        try {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: _loading
                ? Center(child: CircularProgressIndicator())
                : _imageBytes != null
                ? Stack(
                    children: [
                      Center(
                        child: Image.memory(
                          _imageBytes!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 48,
                                  ),
                                  Text(S.of(context).image_load_fail),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withAlpha(125),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.save_outlined),
                                onPressed: _saveImage,
                              ),
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  widget.data.props.remove("imageBase64");
                                  setState(() {
                                    _imageBytes = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 48),
                        Text(S.of(context).loading_error(_errorMessage ?? "")),
                        TextButton(
                          onPressed: _loadImage,
                          child: Text(S.of(context).retry),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 48),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            _pickAndUploadImage();
                          },
                          child: Text(
                            S.of(context).click_upload_image,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        } catch (e) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  Text(S.of(context).loading_error(e)),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
