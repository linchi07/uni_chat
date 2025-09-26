import 'dart:io';
import 'package:uni_chat/Chat/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import '../theme_manager.dart';
import 'chat_models.dart';

// A fixed speed for the typewriter animation.
const int CHARACTERS_PER_SECOND = 400;

class ChatMessageBubble extends ConsumerStatefulWidget {
  final ChatMessage message;
  final bool  enableAnimation;
  const ChatMessageBubble({super.key, required this.message, this.enableAnimation = false});

  @override
  ConsumerState<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

abstract class _ContentBlock {}

class _TextBlock extends _ContentBlock {
  final String content;
  _TextBlock(this.content);
}

class _UiqlBlock extends _ContentBlock {
  bool isComplete = false;
}

class _ChatMessageBubbleState extends ConsumerState<ChatMessageBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<int> _characterCount;

  final List<_ContentBlock> _contentBlocks = [];
  int _processedContentLength = 0;

  final Map<int, bool> _showSourceMap = {};

  static const String _uiqlStartTag = '<UIQL>';
  static const String _uiqlStartTagWithXMLMark = '```xml\n<UIQL>';
  static const String _uiqlEndTag = '</UIQL>';
  static const String _uiqlEndTagWithXMLTagMark = '</UIQL>\n```';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _characterCount = AlwaysStoppedAnimation(widget.message.content.length);
    _updateAnimation();
  }

  @override
  void didUpdateWidget(ChatMessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message.content != oldWidget.message.content) {
      _contentBlocks.clear();
      _processedContentLength = 0;
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    final newContent = widget.message.content;
    final isAiMessage = widget.message.sender == MessageSender.ai;

    if (!isAiMessage || newContent.isEmpty) {
      _controller.value = 1.0;
      _characterCount = AlwaysStoppedAnimation(newContent.length);
      if (mounted) setState(() {});
      return;
    }

    final currentCount = _characterCount.value;
    final newCount = newContent.length;

    if (newCount < currentCount) {
      _characterCount = AlwaysStoppedAnimation(newContent.length);
      _controller.value = 1.0;
      if (mounted) setState(() {});
      return;
    }

    final remainingCount = newCount - currentCount;
    if (remainingCount == 0) return;
    final duration = (widget.enableAnimation)?Duration(
      milliseconds: (1000 * remainingCount) ~/ CHARACTERS_PER_SECOND,
    ): const Duration(milliseconds: 0);
    _controller.duration = duration;
    _characterCount = IntTween(
      begin: currentCount,
      end: newCount,
    ).animate(_controller);
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _processBuffer(String buffer) {
    var lastBlock = _contentBlocks.isNotEmpty ? _contentBlocks.last : null;

    if (lastBlock is _UiqlBlock && !lastBlock.isComplete) {
      // --- We are in UIQL mode, looking for an end tag ---
      final endTagIndex = buffer.indexOf(_uiqlEndTag);
      if (endTagIndex != -1) {
        lastBlock.isComplete = true;
        // Switch back to text mode by processing the rest of the buffer
        String remainingBuffer;
        if (buffer.contains(_uiqlEndTagWithXMLTagMark)) {
          _processedContentLength += endTagIndex + _uiqlEndTagWithXMLTagMark.length;
          remainingBuffer = buffer.substring(
            endTagIndex + _uiqlEndTagWithXMLTagMark.length,
          );
        } else {
          _processedContentLength += endTagIndex + _uiqlEndTag.length;
          remainingBuffer = buffer.substring(
            endTagIndex + _uiqlEndTag.length,
          );
        }
        _processBuffer(remainingBuffer); // Recursive call for remaining buffer
      }
    } else {
      // --- We are in Text mode, looking for a start tag ---
      final startTagIndex = buffer.indexOf(_uiqlStartTag);
      if (startTagIndex != -1) {
        late String textPart;
        var ustwxm = buffer.indexOf(_uiqlStartTagWithXMLMark);
        if (buffer.contains(_uiqlStartTagWithXMLMark)) {
          textPart = buffer.substring(0, ustwxm);
        } else {
          textPart = buffer.substring(0, startTagIndex);
        }
        if (textPart.isNotEmpty) {
          _contentBlocks.add(_TextBlock(textPart));
        }
        _contentBlocks.add(_UiqlBlock());
        _processedContentLength += startTagIndex + _uiqlStartTag.length;
        // Switch to UIQL mode by processing the rest of the buffer
        final remainingBuffer = buffer.substring(
          startTagIndex + _uiqlStartTag.length,
        );
        _processBuffer(remainingBuffer); // Recursive call for remaining buffer
      }
    }
  }

  Widget _buildUiqlCard(_UiqlBlock block, int uiqlIndex) {
    final bool isComplete = block.isComplete;
    final bool isShowingSource = _showSourceMap[uiqlIndex] ?? false;

    final card = Shimmer(
      enabled: !isComplete,
      duration: const Duration(seconds: 1),
      interval: const Duration(seconds: 0),
      colorOpacity: 0.8,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isComplete ? Icons.check_circle : Icons.code,
              color: isComplete ? Colors.green : Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                isComplete ? '编辑了UI' : '正在编辑 UI...',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (isComplete)
              TextButton(
                onPressed: () {
                  setState(() {
                    _showSourceMap[uiqlIndex] = !isShowingSource;
                  });
                },
                child: Text(isShowingSource ? '隐藏源码' : '查看源码'),
              ),
            if (!isComplete) const SizedBox(width: 12),
            if (!isComplete)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        card,
        if (isShowingSource && isComplete) ...[
          const SizedBox(height: 8),
          _buildSourceCodeView(uiqlIndex),
        ],
      ],
    );
  }

  Widget _buildSourceCodeView(int uiqlIndex) {
    final uiqlMatches = RegExp(
      r'<UIQL>[\s\S]*?</UIQL>',
      multiLine: true,
    ).allMatches(widget.message.content).toList();

    if (uiqlIndex >= uiqlMatches.length) {
      return const SizedBox.shrink();
    }

    final source = uiqlMatches[uiqlIndex].group(0)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: GptMarkdown(
        '```xml\n$source\n```',
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUserMessage = widget.message.sender == MessageSender.user;
    List<ChatFile> files = [];

    // 获取所有附件文件
    if (widget.message.attachedFiles != null) {
      for (var fileId in widget.message.attachedFiles!) {
        final file = ref.read(chatStateProvider).uploadedFiles[fileId];
        if (file != null) {
          files.add(file);
        }
      }
    }

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: isUserMessage
            ? BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75)
            : null,
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUserMessage
              ? ref.watch(themeProvider).primaryColor.withAlpha(40)
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (files.isNotEmpty) ...[
              Wrap(
                children: [
                  for (var file in files) _buildAttachmentView(context, file),
                ],
              ),
            ],
            AnimatedBuilder(
              animation: _characterCount,
              builder: (context, child) {
                final totalVisibleChars = _characterCount.value;
                if (totalVisibleChars > _processedContentLength) {
                  final buffer = widget.message.content.substring(
                    _processedContentLength,
                    totalVisibleChars,
                  );
                  _processBuffer(buffer);
                }

                List<Widget> builtWidgets = [];
                String liveText = '';
                int uiqlBlockCount = 0;

                for (var block in _contentBlocks) {
                  if (block is _TextBlock) {
                    builtWidgets.add(
                      GptMarkdown(
                        block.content,
                        useDollarSignsForLatex: true,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    );
                  } else if (block is _UiqlBlock) {
                    builtWidgets.add(_buildUiqlCard(block, uiqlBlockCount++));
                  }
                }

                final lastBlock = _contentBlocks.isNotEmpty
                    ? _contentBlocks.last
                    : null;
                if (lastBlock == null ||
                    (lastBlock is _UiqlBlock && lastBlock.isComplete)) {
                  liveText = widget.message.content.substring(
                    _processedContentLength,
                    totalVisibleChars,
                  );
                }

                if (_controller.isAnimating && liveText.isNotEmpty) {
                  liveText += '▍';
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...builtWidgets,
                    if (liveText.isNotEmpty)
                      GptMarkdown(
                        liveText,
                        useDollarSignsForLatex: true,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentView(BuildContext context, ChatFile file) {
    final isImage = file.type == FileTypeDefine.image;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: isImage
          ? Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              height: 100,
              child: FutureBuilder<File>(
                future: file.getFile(), // 假设这是您的异步方法
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return Image.file(snapshot.data!, fit: BoxFit.cover);
                  } else if (snapshot.hasError) {
                    return Icon(Icons.error);
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            )
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[200],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 24,
                      color: ref.read(themeProvider).textColor,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        file.original_name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
