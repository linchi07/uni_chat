import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:uni_chat/Chat/chat_state.dart';
import 'package:uni_chat/utils/chunked_string_buffer.dart';

import '../theme_manager.dart';
import 'chat_models.dart';

// A fixed speed for the typewriter animation.
const int CHARACTERS_PER_SECOND = 400;

class PersistChatMessage extends ConsumerWidget {
  const PersistChatMessage({super.key, required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);
    final isUserMessage = message.sender == MessageSender.user;
    List<ChatFile> files = [];

    // 获取所有附件文件
    if (message.attachedFiles != null) {
      for (var fileId in message.attachedFiles!) {
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
          color: isUserMessage ? theme.boxColor : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (files.isNotEmpty) ...[
              Wrap(
                children: [
                  for (var file in files)
                    _buildAttachmentView(context, file, theme),
                ],
              ),
            ],
            Column(children: BlockParser.parseStaticBlock(message.content)),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentView(
    BuildContext context,
    ChatFile file,
    ThemeConfig theme,
  ) {
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
                      color: theme.textColor,
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

class ChatMessageDynamicStream extends StatefulWidget {
  const ChatMessageDynamicStream({
    super.key,
    required this.contentBuffer,
    required this.refreshFlag,
  });
  final ValueListenable<bool> refreshFlag;
  final ChunkedStringBuffer contentBuffer;
  @override
  State<ChatMessageDynamicStream> createState() =>
      _ChatMessageDynamicStreamState();
}

class _ChatMessageDynamicStreamState extends State<ChatMessageDynamicStream> {
  Timer? _timer; // 添加定时器
  int charDisplayed = 0;
  bool _isAnimating = false; // 添加动画状态标志
  late BlockParser parser;
  @override
  void initState() {
    super.initState();
    parser = BlockParser(widget.contentBuffer);
  }

  @override
  void dispose() {
    _timer?.cancel(); // 清理定时器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.refreshFlag,
      builder: (context, value, child) {
        // 当flag变化且contentBuffer有内容时开始动画
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: StatefulBuilder(
              builder: (context, setState) {
                if (widget.contentBuffer.length > charDisplayed &&
                    !_isAnimating) {
                  //此处的set state只会激活 StatefulBuilder中的setState
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    enableAnimation(setState);
                  });
                }
                if (blocksToDisplay.isEmpty) return const _Loading();
                return Column(children: blocksToDisplay);
              },
            ),
          ),
        );
      },
    );
  }

  List<Widget> blocksToDisplay = [];

  void enableAnimation(dynamic setState) {
    const charactersPerSecond = 80; // 每秒字符数
    _isAnimating = true;
    // 每秒刷新 charactersPerSecond 次，每次只添加一个字符
    const interval = Duration(microseconds: 1000000 ~/ charactersPerSecond);
    _timer = Timer.periodic(interval, (timer) {
      setState(() {
        if (charDisplayed < widget.contentBuffer.length) {
          blocksToDisplay = parser.parseDynamicBlockWithLimit(++charDisplayed);
        } else {
          // 显示完成，停止定时器
          _timer?.cancel();
          _isAnimating = false;
        }
      });
    });
  }
}

class _Loading extends StatelessWidget {
  const _Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(color: Colors.black),
    );
  }
}

class _TextBlock extends StatelessWidget {
  const _TextBlock({super.key, required this.content});
  final String content;
  @override
  Widget build(BuildContext context) {
    return GptMarkdown(
      content,
      useDollarSignsForLatex: true,
      style: const TextStyle(color: Colors.black, fontSize: 16),
    );
  }
}

class _UiqlBlock extends StatefulWidget {
  const _UiqlBlock({super.key, required this.isComplete, this.content});
  final bool isComplete;
  final String? content;
  @override
  State<_UiqlBlock> createState() => _UiqlBlockState();
}

class _UiqlBlockState extends State<_UiqlBlock> {
  bool isShowingSource = false;
  @override
  Widget build(BuildContext context) {
    final card = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Shimmer(
        enabled: !widget.isComplete,
        duration: const Duration(seconds: 3),
        interval: const Duration(seconds: 0),
        colorOpacity: 0.8,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isComplete ? Icons.check_circle : Icons.code,
                color: widget.isComplete
                    ? Colors.green
                    : Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  widget.isComplete ? '编辑了UI' : '正在编辑 UI...',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (widget.isComplete)
                TextButton(
                  onPressed: () {
                    setState(() {
                      isShowingSource = !isShowingSource;
                    });
                  },
                  child: Text(isShowingSource ? '隐藏源码' : '查看源码'),
                ),
              if (!widget.isComplete) const SizedBox(width: 12),
              if (!widget.isComplete)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                ),
            ],
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        card,
        if (isShowingSource && widget.isComplete) ...[
          const SizedBox(height: 8),
          _buildSourceCodeView(widget.content),
        ],
      ],
    );
  }

  Widget _buildSourceCodeView(String? source) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: GptMarkdown(
        '```xml\n<uiql>$source</uiql>\n```',
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({super.key, required this.content});
  final String content;
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(12),
      ),
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              '发生错误：$content',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonBlock extends StatefulWidget {
  const _ReasonBlock({super.key, required this.isComplete, this.content});
  final bool isComplete;
  final String? content;
  @override
  State<_ReasonBlock> createState() => _ReasonBlockState();
}

class _ReasonBlockState extends State<_ReasonBlock>
    with SingleTickerProviderStateMixin {
  double elapsedTime = 0; // 添加这一行
  Timer? timer; // 添加计时器
  bool isTimerSet = false;
  bool isShowing = false;
  bool animatedDirection = true;
  late AnimationController _animationController;
  late Animation<double> _opacity;
  dynamic listener;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    listener = (status) {
      if (widget.isComplete && animatedDirection) {
        _animationController.removeStatusListener(listener);
      }
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        if (animatedDirection) {
          Future.delayed(
            const Duration(milliseconds: 500),
            () => _animationController.reverse(),
          );
          animatedDirection = !animatedDirection;
        } else {
          Future.delayed(
            const Duration(milliseconds: 500),
            () => _animationController.forward(),
          );
          animatedDirection = !animatedDirection;
        }
      }
    };
    _animationController.addStatusListener(listener);
    _animationController.forward();
  }

  @override
  void dispose() {
    timer?.cancel(); // 取消计时器
    _animationController.removeStatusListener(listener);
    _animationController.dispose();
    super.dispose();
  }

  void startTimer(dynamic setState) {
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!widget.isComplete && mounted) {
        isTimerSet = true;
        setState(() {
          elapsedTime += 0.1;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Shimmer(
        enabled: !widget.isComplete,
        duration: const Duration(seconds: 3),
        interval: const Duration(seconds: 0),
        colorOpacity: 0.8,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _opacity,
                builder: (context, child) {
                  return Opacity(opacity: _opacity.value, child: child!);
                },
                child: Icon(
                  widget.isComplete
                      ? Icons.check_circle
                      : Icons.lightbulb_outline,
                  color: widget.isComplete
                      ? Colors.green
                      : Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    if (!widget.isComplete && !isTimerSet) {
                      startTimer(setState);
                    }
                    return Text(
                      widget.isComplete
                          ? '思考了${elapsedTime.toStringAsFixed(1)}秒'
                          : '正在思考${elapsedTime.toStringAsFixed(1)}秒... ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
              if (widget.isComplete)
                TextButton(
                  onPressed: () {
                    setState(() {
                      isShowing = !isShowing;
                    });
                  },
                  child: Text(isShowing ? '隐藏思维链' : '查看思维链'),
                ),
              if (!widget.isComplete) const SizedBox(width: 12),
              if (!widget.isComplete)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                ),
            ],
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        card,
        if (isShowing && widget.isComplete) ...[
          const SizedBox(height: 8),
          _buildSourceCodeView(widget.content),
        ],
      ],
    );
  }

  Widget _buildSourceCodeView(String? source) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: GptMarkdown(
        source ?? '',
        style: const TextStyle(color: Colors.black, fontSize: 14),
      ),
    );
  }
}

class _RagBlock extends StatefulWidget {
  const _RagBlock({super.key, required this.isComplete, this.content});
  final bool isComplete;
  final String? content;
  @override
  State<_RagBlock> createState() => _RagBlockState();
}

class _RagBlockState extends State<_RagBlock>
    with SingleTickerProviderStateMixin {
  bool animatedDirection = true;
  bool isShowing = false;
  late AnimationController _animationController;
  late Animation<double> _opacity;
  dynamic listener;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    listener = (status) {
      if (widget.isComplete && animatedDirection) {
        _animationController.removeStatusListener(listener);
      }
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        if (animatedDirection) {
          Future.delayed(
            const Duration(milliseconds: 500),
            () => _animationController.reverse(),
          );
          animatedDirection = !animatedDirection;
        } else {
          Future.delayed(
            const Duration(milliseconds: 500),
            () => _animationController.forward(),
          );
          animatedDirection = !animatedDirection;
        }
      }
    };
    _animationController.addStatusListener(listener);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.removeStatusListener(listener);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Shimmer(
        enabled: !widget.isComplete,
        duration: const Duration(seconds: 3),
        interval: const Duration(seconds: 0),
        colorOpacity: 0.8,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _opacity,
                builder: (context, child) {
                  return Opacity(opacity: _opacity.value, child: child!);
                },
                child: Icon(
                  widget.isComplete ? Icons.check_circle : Icons.search,
                  color: widget.isComplete
                      ? Colors.green
                      : Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  widget.isComplete ? '检索了知识库' : '正在检索知识库... ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (widget.isComplete)
                TextButton(
                  onPressed: () {
                    setState(() {
                      isShowing = !isShowing;
                    });
                  },
                  child: Text(isShowing ? '隐藏内容' : '查看检索结果'),
                ),
              if (!widget.isComplete) const SizedBox(width: 12),
              if (!widget.isComplete)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                ),
            ],
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        card,
        if (isShowing && widget.isComplete) ...[
          const SizedBox(height: 8),
          _buildSourceCodeView(widget.content),
        ],
      ],
    );
  }

  Widget _buildSourceCodeView(String? source) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: GptMarkdown(
        source ?? '',
        style: const TextStyle(color: Colors.black, fontSize: 14),
      ),
    );
  }
}

class BlockParser {
  static Map<String, dynamic> targetXMLs = {
    'UIQL': (b, content) {
      return _UiqlBlock(isComplete: b, content: content);
    },
    'error': (b, content) {
      return _ErrorBlock(content: content);
    },
    'think': (b, content) {
      return _ReasonBlock(isComplete: b, content: content);
    },
    'rag': (b, content) {
      return _RagBlock(isComplete: b, content: content);
    },
  };

  static List<Widget> parseStaticBlock(String content) {
    final List<Widget> blocks = [];

    // 如果内容为空或目标map为空，直接返回
    if (content.isEmpty) {
      return blocks;
    }
    if (targetXMLs.isEmpty) {
      blocks.add(_TextBlock(content: content));
      return blocks;
    }

    // 1. 动态构建一个能匹配所有目标标签的正则表达式
    final tagNames = targetXMLs.keys.join('|');
    //    正则表达式解释:
    //    - <($tagNames)>: 匹配一个开标签，并将标签名(如 UIQL)捕获到分组1
    //    - (.*?): 非贪婪地匹配标签内的所有内容，并捕获到分组2
    //    - <\/\\1>: 匹配一个闭标签，\\1 是反向引用，确保闭标签和开标签同名
    final RegExp regExp = RegExp('<($tagNames)>(.*?)</\\1>', dotAll: true);

    int currentIndex = 0;
    final Iterable<RegExpMatch> matches = regExp.allMatches(content);

    // 2. 遍历所有匹配到的标签
    for (final match in matches) {
      // 添加匹配标签之前的文本部分
      if (match.start > currentIndex) {
        final textContent = content.substring(currentIndex, match.start);
        if (textContent.trim().isNotEmpty) {
          blocks.add(_TextBlock(content: textContent));
        }
      }

      // 3. 处理并添加匹配到的XML Block
      final tagName = match.group(1)!; // 分组1: 标签名
      final tagContent = match.group(2) ?? ''; // 分组2: 标签内容

      // 从map中找到对应的构造函数并创建Widget
      final blockFactory = targetXMLs[tagName]!;
      blocks.add(blockFactory(true, tagContent));

      // 更新当前处理位置
      currentIndex = match.end;
    }

    // 4. 添加最后一个匹配标签之后剩余的文本
    if (currentIndex < content.length) {
      final remainingText = content.substring(currentIndex);
      if (remainingText.trim().isNotEmpty) {
        blocks.add(_TextBlock(content: remainingText));
      }
    }

    // 如果没有任何匹配，将全部内容视为一个文本块
    if (blocks.isEmpty && content.trim().isNotEmpty) {
      blocks.add(_TextBlock(content: content));
    }

    return blocks;
  }

  _ParseState state = _ParseState.findingTagStartMark;
  String tagName = '';
  String endTagName = '';
  ChunkedStringBuffer fullBuffer;
  var blockStartPointer = 0;
  late ChunkedStringBuffer parseBuffer;
  BlockParser(this.fullBuffer) {
    parseBuffer = fullBuffer.clone();
  }
  List<Widget> blocksCached = [];

  ///当时设计解析器的时候忘记考虑到这一点了
  ///只能打补丁了
  List<Widget> parseDynamicBlockWithLimit(int charLimit) {
    parseBuffer = fullBuffer.subBuffer(parseBuffer.toMasterIndex(0), charLimit);
    return parseDynamicBlock();
  }

  /// 动态解析
  /// 从缓冲区中直接解析，无需输入内容
  List<Widget> parseDynamicBlock() {
    //这里分为三个步骤，第一个是已经固化的内容，这部分只存在于blocks cached中
    //第二是buffer，这里是所有没有固化的内容
    //第三是tmp buffer 这里每次都会重创建，然后内部通过消费缓冲区的内容，生成block
    //例如第二个缓冲中假如有了 <UIQ ,此时第三个缓冲区会先消费掉所有的内容生成一个文本块
    //当下一次流更新的时候 假如buffer变为了<UIQL> 那么就可以生成UIQL块，否则假如是 <UIQD>比如说，那么就会生成一个文本块
    //这就是三个buffer的意义
    List<Widget> blocks = [];
    var tmpBuffer = parseBuffer.clone();
    //还有为了能够让两个缓冲区的索引同步，所有的索引都是通过master index（他两共有）来计算，并且转换到对应的local 索引中的
    var pointer = tmpBuffer.toMasterIndex(0);
    while (tmpBuffer.length > 0) {
      switch (state) {
        // 寻找标签的开始
        case _ParseState.findingTagStartMark:
          bool breakFlag = false;
          var forLim = tmpBuffer.toMasterIndex(tmpBuffer.length);
          for (var i = pointer; i < forLim; i++) {
            if (tmpBuffer[tmpBuffer.fromMasterIndex(i)] == '<') {
              state = _ParseState.inStartTag;
              pointer = i;
              breakFlag = true;
              break;
            }
          }
          //当找到了<，则进入下一个状态，直接漏进去，不用break
          if (!breakFlag) {
            //当没有找到<，则将缓冲区中的所有内容作为文本块添加到结果中
            if (tmpBuffer.length > 0) {
              blocks.add(
                _TextBlock(content: tmpBuffer.toStringWithTrailing("▍")),
              );
              tmpBuffer.pop(tmpBuffer.length);
              break;
            }
          }
        case _ParseState.inStartTag:
          //当我们在标签开始的时候，我们开始寻找标签的结束
          //即使没有找到结束，我们也需要将所有的内容作为文本块添加到结果中
          bool breakFlag = false;
          var forLim = tmpBuffer.toMasterIndex(tmpBuffer.length);
          //寻找标签的结束
          for (var i = pointer; i < forLim; i++) {
            if (tmpBuffer[tmpBuffer.fromMasterIndex(i)] == '>') {
              var l = tmpBuffer.fromMasterIndex(pointer) + 1;
              var l2 = tmpBuffer.fromMasterIndex(i) + 1;
              if (tmpBuffer.length > l && tmpBuffer.length > l2) {
                //防止出界
                //当找到标签的结束，首先记下标签
                tagName = tmpBuffer.substring(
                  tmpBuffer.fromMasterIndex(pointer + 1),
                  tmpBuffer.fromMasterIndex(i),
                );
              } else {
                break;
              }
              endTagName = '</$tagName>';
              //如果该标签在目标XMLs中，则将标签前的所有东西固化为一个文本块，并添加到结果中
              //这里可以直接忽略固化的东西，也就是将buffer被添加到文本块中的内容给pop掉
              if (targetXMLs.containsKey(tagName)) {
                blocksCached.add(
                  _TextBlock(
                    content: tmpBuffer.substring(
                      0,
                      tmpBuffer.fromMasterIndex(pointer),
                    ),
                  ),
                );
                parseBuffer.popToIndex(parseBuffer.fromMasterIndex(i));
                tmpBuffer.popToIndex(tmpBuffer.fromMasterIndex(i));
                state = _ParseState.matchingEndTagMark;
                blockStartPointer = i + 1;
                pointer = i + 1;
                breakFlag = true;
                break;
              } else {
                state = _ParseState.findingTagStartMark;
                pointer = i;
                breakFlag = true;
                break;
              }
            }
          }
          //如果寻找到完整的起始标签依然只是一层break,漏到下一层
          if (!breakFlag) {
            //当没有找到>，则将缓冲区中的所有内容作为文本块添加到结果中
            if (tmpBuffer.length > 0) {
              blocks.add(
                _TextBlock(content: tmpBuffer.toStringWithTrailing("▍")),
              );
              tmpBuffer.pop(tmpBuffer.length);
              break;
            }
          }
        case _ParseState.matchingEndTagMark:
          //不断的寻找结束标签的开始（这TM怎么这么绕）
          bool breakFlag = false;
          var forLim = tmpBuffer.toMasterIndex(tmpBuffer.length);
          for (var i = pointer; i < forLim; i++) {
            if (tmpBuffer[tmpBuffer.fromMasterIndex(i)] == '<') {
              state = _ParseState.matchingEndTag;
              pointer = i;
              //注意此时还不能固化，因为这个结束标签可能是无效的也就是不match开始标签
              breakFlag = true;
              break;
            }
          }
          //如果还没结束也就是没有找到<，那么就继续添加到文本块中
          if (!breakFlag) {
            if (tmpBuffer.length == 0) {
              break;
            }
            blocks.add(
              targetXMLs[tagName]!(
                false,
                tmpBuffer.substring(
                  tmpBuffer.fromMasterIndex(blockStartPointer),
                ),
              ),
            );
            tmpBuffer.pop(tmpBuffer.length);
            break;
          }
        case _ParseState.matchingEndTag:
          //采用状态机器完全匹配end tag
          if (tmpBuffer.length <
              endTagName.length + tmpBuffer.fromMasterIndex(pointer)) {
            //当缓冲区长度小于endTagName长度，则end tag肯定不全（也有可能是完全不是）
            //此时直接全部添加到文本块中
            blocks.add(
              targetXMLs[tagName]!(
                false,
                tmpBuffer.substring(
                  tmpBuffer.fromMasterIndex(blockStartPointer),
                ),
              ),
            );
            tmpBuffer.pop(tmpBuffer.length);
            break;
          }
          bool notFound = false;
          //当缓冲区长度大于等于endTagName长度，则开始匹配
          var forLim = endTagName.length + pointer;
          for (var i = pointer; i < forLim; i++) {
            if (tmpBuffer[tmpBuffer.fromMasterIndex(i)] !=
                endTagName[i - pointer]) {
              pointer = i;
              //如果任意状态匹配失败，则将状态machine重置为matchingEndTagMark
              //这个时候那边会将多余的字符串给塞到block中，这里就不需要处理了
              state = _ParseState.matchingEndTagMark;
              notFound = true;
              break;
            }
          }
          if (notFound) {
            //需要连续break两次才能跳回循环
            break;
          }
          //如果匹配成功就固化
          if (blocks.isNotEmpty) {
            //gpt强烈要求我边界保护，其实我觉得没必要，因为逻辑上来讲，这里不可能为空
            //但是我的逻辑水平，我还是相信gpt吧
            blocks.removeLast();
          }
          blocksCached.add(
            targetXMLs[tagName]!(
              true,
              tmpBuffer.substring(0, tmpBuffer.fromMasterIndex(pointer)),
            ),
          );
          parseBuffer.popToIndex(
            parseBuffer.fromMasterIndex(pointer + endTagName.length - 1),
          );
          tmpBuffer.popToIndex(
            tmpBuffer.fromMasterIndex(pointer + endTagName.length - 1),
          );
          pointer = pointer + endTagName.length;
          state = _ParseState.findingTagStartMark;
        //此时会跳回start，由那边把缓冲区中的剩余内容给添加到文本块中（或者开始新一轮匹配）
      }
    }
    blocks = [...blocksCached, ...blocks];
    return blocks;
  }
}

enum _ParseState {
  findingTagStartMark,
  inStartTag,
  matchingEndTagMark,
  matchingEndTag,
}
