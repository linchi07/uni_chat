import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:uni_chat/Agent/agentProvider.dart';
import 'package:uni_chat/Persona/persona_provider.dart';
import 'package:uni_chat/utils/database_service.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';
import 'package:uuid/uuid.dart';

import '../theme_manager.dart';
import '../utils/dialog.dart';
import 'chat_message_bubble.dart';
import 'chat_models.dart';
import 'chat_state.dart';

class _AgentDropDown extends ConsumerStatefulWidget {
  const _AgentDropDown({super.key});
  @override
  ConsumerState<_AgentDropDown> createState() => _AgentDropDownState();
}

class _AgentDropDownState extends ConsumerState<_AgentDropDown>
    with SingleTickerProviderStateMixin {
  (String, String)? selectedIndex;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.7, curve: Curves.easeInOut), // 前半段时间执行
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);
    var agent = ref.watch(agentProvider);
    if (agent != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedIndex = (agent.id, agent.name);
        });
      });
    }
    return SizedBox(
      height: 40,
      width: 180,
      child: Material(
        clipBehavior: Clip.hardEdge,
        color: theme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          onTap: () {
            var rb = context.findRenderObject() as RenderBox;
            OverlayPortalService.show(
              context,
              barrierVisible: false,
              offset: rb.localToGlobal(Offset.zero),
              // 这是你要求修改的部分
              child: SizeTransition(
                sizeFactor: _scaleAnimation,
                child: SizedBox(
                  width: rb.size.width + 4,
                  height: rb.size.height * 5 + 3,
                  child: Material(
                    elevation: 4,
                    color: theme.surfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FutureBuilder(
                      future: DatabaseService.instance.getAllAgents(),
                      builder: (context, asyncSnapshot) {
                        if (asyncSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (asyncSnapshot.data == null) {
                          return const Center(child: Text("发生错误"));
                        }
                        return Column(
                          children: [
                            // 这个三元运算符可以简化
                            if (selectedIndex != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(width: 16.0),
                                    const FlutterLogo(size: 25),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        selectedIndex!.$2,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: theme.textColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const Divider(),
                            if (asyncSnapshot.data!.isEmpty)
                              const Center(child: Text('没有agent')),
                            Expanded(
                              child: (_scaleAnimation.isCompleted)
                                  ? SizedBox()
                                  : ListView.builder(
                                      itemCount: asyncSnapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        return StdListTile(
                                          onTap: () async {
                                            OverlayPortalService.hide(context);
                                            await ref
                                                .read(agentProvider.notifier)
                                                .loadAgentById(
                                                  asyncSnapshot.data![index].id,
                                                );
                                          },
                                          title: Text(
                                            asyncSnapshot.data![index].name,
                                          ),
                                          leading: const FlutterLogo(),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
            // 启动动画 (这个是必须的)
            _controller.forward(from: 0.0);
          },
          child: (selectedIndex == null)
              ? Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "请选择Agent",
                        style: TextStyle(fontSize: 16, color: theme.textColor),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: theme.textColor),
                    ],
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 16),
                    const FlutterLogo(size: 25),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        selectedIndex!.$2,
                        style: TextStyle(fontSize: 16, color: theme.textColor),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: theme.textColor),
                    const SizedBox(width: 16),
                  ],
                ),
        ),
      ),
    );
  }
}

class _PersonaDropDown extends ConsumerStatefulWidget {
  const _PersonaDropDown({super.key});
  @override
  ConsumerState<_PersonaDropDown> createState() => _PersonaDropDownState();
}

class _PersonaDropDownState extends ConsumerState<_PersonaDropDown>
    with SingleTickerProviderStateMixin {
  (String, String)? selectedIndex;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.7, curve: Curves.easeInOut), // 前半段时间执行
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);
    var persona = ref.watch(personaProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        selectedIndex = (persona.id, persona.name);
      });
    });
    return SizedBox(
      height: 40,
      width: 180,
      child: Material(
        clipBehavior: Clip.hardEdge,
        color: theme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          onTap: () {
            var rb = context.findRenderObject() as RenderBox;
            OverlayPortalService.show(
              context,
              barrierVisible: false,
              offset: rb.localToGlobal(Offset.zero),
              // 这是你要求修改的部分
              child: SizeTransition(
                sizeFactor: _scaleAnimation,
                child: SizedBox(
                  width: rb.size.width + 4,
                  height: rb.size.height * 5 + 3,
                  child: Material(
                    elevation: 4,
                    color: theme.surfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FutureBuilder(
                      future: DatabaseService.instance.getAllPersonas(),
                      builder: (context, asyncSnapshot) {
                        if (asyncSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (asyncSnapshot.data == null) {
                          return const Center(child: Text("发生错误"));
                        }
                        return Column(
                          children: [
                            // 这个三元运算符可以简化
                            if (selectedIndex != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(width: 16.0),
                                    const FlutterLogo(size: 25),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        selectedIndex!.$2,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: theme.textColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const Divider(),
                            if (asyncSnapshot.data!.isEmpty)
                              const Center(child: Text('没有人格')),
                            Expanded(
                              child: (_scaleAnimation.isCompleted)
                                  ? SizedBox()
                                  : ListView.builder(
                                      itemCount: asyncSnapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        return StdListTile(
                                          onTap: () async {
                                            OverlayPortalService.hide(context);
                                            await ref
                                                .read(personaProvider.notifier)
                                                .loadPersonaById(
                                                  asyncSnapshot.data![index].id,
                                                );
                                          },
                                          title: Text(
                                            asyncSnapshot.data![index].name,
                                          ),
                                          leading: const FlutterLogo(),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
            // 启动动画 (这个是必须的)
            _controller.forward(from: 0.0);
          },
          child: (selectedIndex == null)
              ? Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "请选择人格",
                        style: TextStyle(fontSize: 16, color: theme.textColor),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: theme.textColor),
                    ],
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 16),
                    const FlutterLogo(size: 25),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        selectedIndex!.$2,
                        style: TextStyle(fontSize: 16, color: theme.textColor),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: theme.textColor),
                    const SizedBox(width: 16),
                  ],
                ),
        ),
      ),
    );
  }
}

class ChatPanelWhenNoSession extends ConsumerWidget {
  const ChatPanelWhenNoSession({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "一起集思广益！",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "选择一个Agent并开始聊天吧！",
              style: TextStyle(fontSize: 16, color: theme.boxColor),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("以  ", style: TextStyle(fontSize: 18)),
                _PersonaDropDown(),
                Text("  和  ", style: TextStyle(fontSize: 18)),
                _AgentDropDown(),
                Text("  开始聊天", style: TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: MediaQuery.of(context).size.width.clamp(0, 800),
              child: ChatPanelInputBox(),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatPanel extends ConsumerWidget {
  const ChatPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatStateProvider);
    final messages = chatState.messages;
    return Scaffold(
      backgroundColor: ref.watch(themeProvider).backgroundColor,
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width.clamp(0, 1000),
          child: Column(
            children: [
              Expanded(
                child: SelectionArea(
                  selectionControls: MaterialTextSelectionControls(),
                  child: ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];
                      return ChatMessageBubble(
                        message: message,
                        enableAnimation:
                            (index == messages.length - 1 &&
                            chatState.isLoading),
                      );
                    },
                  ),
                ),
              ),
              const ChatPanelInputBox(),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatPanelInputBox extends ConsumerStatefulWidget {
  const ChatPanelInputBox({super.key});

  @override
  ConsumerState<ChatPanelInputBox> createState() => _ChatPanelInputBoxState();
}

enum UploadStatus { notUploaded, uploading, uploaded, failed }

class _ChatPanelInputBoxState extends ConsumerState<ChatPanelInputBox> {
  final _textController = TextEditingController();
  bool isDroppingFiles = false;
  late ThemeConfig theme;
  @override
  initState() {
    super.initState();
  }

  // Use a list to support multiple attachments in the future
  final List<(String, UploadStatus)> _attachments = []; // 改为存储文件ID
  final Uuid _uuid = const Uuid();

  bool _isUploading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true, // 允许选择多个文件
    );

    if (result != null) {
      for (var file in result.files) {
        if (file.path != null) {
          final actualFile = File(file.path!);
          final previewId = _uuid.v4();
          // 添加预览ID到附件列表
          setState(() {
            _isUploading = true;
            _attachments.add((previewId, UploadStatus.uploading));
          });
          final appDocDir = await getApplicationDocumentsDirectory();
          final sessionFilesDir = Directory(
            '${appDocDir.path}/chat/session_files',
          );
          if (!await sessionFilesDir.exists()) {
            await sessionFilesDir.create(recursive: true);
          }

          // 使用UUID生成新的文件名
          final newFileName = previewId + p.extension(actualFile.path);
          final newFilePath = '${sessionFilesDir.path}/$newFileName';

          // 拷贝文件到新位置
          final copiedFile = await actualFile.copy(newFilePath);

          // Trigger the upload via the notifier
          final uploadedFileId = await ref
              .read(chatStateProvider.notifier)
              .triggerUploadFile(
                copiedFile,
                previewId,
                p.basename(actualFile.path),
              );

          // 注意：这里不再更新附件状态，因为文件信息现在存储在ChatState中
          if (uploadedFileId == null) {
            // 上传失败，从附件列表中移除
            setState(() {
              _isUploading = false;
              _attachments[_attachments.indexWhere(
                (id) => id.$1 == previewId,
              )] = (
                previewId,
                UploadStatus.failed,
              );
            });
          } else {
            // 更新附件状态为上传成功
            setState(() {
              _isUploading = false;
              _attachments[_attachments.indexWhere(
                (id) => id.$1 == previewId,
              )] = (
                previewId,
                UploadStatus.uploaded,
              );
            });
          }
        }
      }
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();

    if (text.isEmpty && _attachments.isEmpty) return;
    if (_isUploading) return; // Prevent sending while an upload is in progress
    List<String> attachedFiles = [];
    for (var a in _attachments) {
      attachedFiles.add(a.$1);
    }
    ref
        .read(chatStateProvider.notifier)
        .sendMessage(
          text,
          attachedFiles: _attachments.isEmpty ? null : attachedFiles,
        );

    _textController.clear();
    setState(() {
      _attachments.clear();
    });
  }

  Future<void> _readAndAttachFile(dynamic f, String fileExtension) async {
    var previewId = _uuid.v4();
    setState(() {
      _isUploading = true;
      _attachments.add((previewId, UploadStatus.uploading));
    });
    final appDocDir = await getApplicationDocumentsDirectory();
    final sessionFilesDir = Directory('${appDocDir.path}/chat/session_files');
    if (!await sessionFilesDir.exists()) {
      await sessionFilesDir.create(recursive: true);
    }
    final file = File("${sessionFilesDir.path}/$previewId$fileExtension");
    final sink = file.openWrite();
    await f.getStream().forEach(sink.add);
    await sink.close();
    final uploadedFileId = await ref
        .read(chatStateProvider.notifier)
        .triggerUploadFile(
          file,
          previewId,
          f.fileName ?? DateTime.now().toIso8601String() + fileExtension,
        );
    // 注意：这里不再更新附件状态，因为文件信息现在存储在ChatState中
    if (uploadedFileId == null) {
      // 上传失败，从附件列表中移除
      setState(() {
        _isUploading = false;
        var id = _attachments.indexWhere((id) => id.$1 == previewId);
        if (id != -1) {
          _attachments[id] = (previewId, UploadStatus.failed);
        }
      });
    } else {
      // 更新附件状态为上传成功
      setState(() {
        _isUploading = false;
        var id = _attachments.indexWhere((id) => id.$1 == previewId);
        if (id != -1) {
          _attachments[id] = (previewId, UploadStatus.uploaded);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final globalLoading = ref.watch(
      chatStateProvider.select((s) => s.isLoading),
    );
    theme = ref.watch(themeProvider);
    final isSendButtonDisabled =
        _isUploading || (globalLoading && _attachments.isEmpty);
    late Widget childPanel;
    if (isDroppingFiles) {
      childPanel = Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
        color: Colors.white.withAlpha(180),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AbsorbPointer(child: _buildChatPanel(isSendButtonDisabled)),
            Text(
              'Drop files here',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
      );
    } else {
      childPanel = Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
        child: _buildChatPanel(isSendButtonDisabled),
      );
    }
    return DropRegion(
      formats: Formats.standardFormats,
      onDropOver: (d) {
        if (d.session.allowedOperations.contains(DropOperation.copy)) {
          setState(() {
            isDroppingFiles = true;
          });
          return DropOperation.copy;
        }
        return DropOperation.none;
      },
      onPerformDrop: (e) async {
        var item = e.session.items.first;
        if (item.dataReader == null) {
          return;
        }
        //啊没错，这个包就不能提供一个获取拓展名的方法，非要这样搞
        //而且他就不能提供一个file的类型的返回值，非要我一个个去读取。。。。
        if (item.canProvide(Formats.jpeg)) {
          item.dataReader?.getFile(
            Formats.jpeg,
            (f) async {
              await _readAndAttachFile(f, ".jpeg");
            },
            onError: (error) {
              return;
            },
          );
        } else if (item.canProvide(Formats.png)) {
          item.dataReader?.getFile(
            Formats.png,
            (f) async {
              await _readAndAttachFile(f, ".png");
            },
            onError: (error) {
              return;
            },
          );
        } else if (item.canProvide(Formats.pdf)) {
          item.dataReader?.getFile(
            Formats.pdf,
            (f) async {
              await _readAndAttachFile(f, ".pdf");
            },
            onError: (error) {
              return;
            },
          );
        } else if (item.canProvide(Formats.json)) {
          item.dataReader?.getFile(
            Formats.json,
            (f) async {
              await _readAndAttachFile(f, ".json");
            },
            onError: (error) {
              return;
            },
          );
        } else if (item.canProvide(Formats.csv)) {
          item.dataReader?.getFile(
            Formats.csv,
            (f) async {
              await _readAndAttachFile(f, ".csv");
            },
            onError: (error) {
              return;
            },
          );
        }
        if (item.canProvide(Formats.htmlFile)) {
          item.dataReader?.getFile(
            Formats.htmlFile,
            (f) async {
              await _readAndAttachFile(f, ".html");
            },
            onError: (error) {
              return;
            },
          );
        } else if (item.canProvide(Formats.md)) {
          item.dataReader?.getFile(
            Formats.md,
            (f) async {
              await _readAndAttachFile(f, ".md");
            },
            onError: (error) {
              return;
            },
          );
        } else
        //但愿他的意思是typescript，不是什么奇葩
        if (item.canProvide(Formats.ts)) {
          item.dataReader?.getFile(
            Formats.ts,
            (f) async {
              await _readAndAttachFile(f, ".ts");
            },
            onError: (error) {
              return;
            },
          );
        } else if (item.canProvide(Formats.plainTextFile)) {
          item.dataReader?.getFile(
            Formats.plainTextFile,
            (f) async {
              await _readAndAttachFile(f, p.extension(f.fileName ?? ".txt"));
            },
            onError: (error) {
              return;
            },
          );
          //plaintext必须放在最后，不然markdown的格式可能会变成text，很奇葩的问题
        } else if (item.canProvide(Formats.plainText)) {
          item.dataReader?.getValue<String>(
            Formats.plainText,
            (value) {
              if (value != null) {
                _textController.text += value;
              }
            },
            onError: (error) {
              return;
            },
          );
        }
      },
      onDropLeave: (e) {
        setState(() {
          isDroppingFiles = false;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: theme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: childPanel,
      ),
    );
  }

  late final _focusNode = FocusNode(
    onKeyEvent: (FocusNode node, KeyEvent evt) {
      if (!HardwareKeyboard.instance.isShiftPressed &&
          evt.logicalKey == LogicalKeyboardKey.enter) {
        if (evt is KeyDownEvent) {
          _sendMessage();
        }
        return KeyEventResult.handled;
      } else {
        //这里的机制是，text field对于shift+enter他依然会换行，所以我们只需要单独拦截一个enter键让他直接发送就可以完全符合要求
        return KeyEventResult.ignored;
      }
    },
  );

  Widget _buildChatPanel(bool isSendButtonDisabled) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_attachments.isNotEmpty) _buildAttachmentPreview(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2),
          child: TextField(
            focusNode: _focusNode,
            maxLines: 7,
            minLines: 2,
            controller: _textController,
            decoration: const InputDecoration.collapsed(
              hintText: 'Send a message...',
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _pickFile,
              tooltip: 'Attach File',
            ),
            const Spacer(),
            SizedBox(
              height: 35,
              width: 35,
              child: Material(
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                color: isSendButtonDisabled
                    ? Colors.grey[600]
                    : theme.primaryColor,
                child: InkWell(
                  splashColor: Colors.grey,
                  onTap: isSendButtonDisabled ? null : _sendMessage,
                  child: isSendButtonDisabled
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(7.0),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.arrow_forward_sharp,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttachmentPreview() {
    final chatState = ref.watch(chatStateProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 10, right: 10),
      child: SizedBox(
        height: 60,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _attachments.length,
          itemBuilder: (context, index) {
            final attachmentId = _attachments[index];
            final chatFile = chatState.uploadedFiles[attachmentId.$1];

            return _buildAttachmentPreviewItem(
              chatFile,
              attachmentId.$2,
              index,
            );
          },
        ),
      ),
    );
  }

  Widget _buildAttachmentPreviewItem(
    ChatFile? chatFile,
    UploadStatus status,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 基础预览内容
          Builder(
            builder: (context) {
              if (status == UploadStatus.uploaded && chatFile != null) {
                if (chatFile.type == FileTypeDefine.image) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: FutureBuilder<File>(
                      future: chatFile.getFile(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return Image.file(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                          );
                        } else if (snapshot.hasError) {
                          return Icon(Icons.error, size: 24);
                        } else {
                          return Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                      },
                    ),
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    height: 50,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.description_outlined, size: 24),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              chatFile.original_name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              } else {
                // 默认文件图标（上传中或失败状态）
                return Container(
                  padding: const EdgeInsets.all(8),
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.insert_drive_file, size: 24),
                );
              }
            },
          ),

          // 状态覆盖层
          if (status == UploadStatus.uploading)
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else if (status == UploadStatus.failed ||
              (status == UploadStatus.uploaded && chatFile == null))
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(125),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Icon(Icons.error_outline, color: Colors.red),
                ),
              ),
            ),

          // 关闭按钮
          Positioned(
            top: 0,
            right: -6,
            child: GestureDetector(
              child: const Icon(Icons.cancel, color: Colors.black54, size: 16),
              onTap: () {
                setState(() {
                  _attachments.removeAt(index);
                  if (chatFile != null) {
                    ref
                        .read(chatStateProvider)
                        .uploadedFiles
                        .remove(chatFile.name);
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
