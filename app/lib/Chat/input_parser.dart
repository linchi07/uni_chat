import 'package:uni_chat/Chat/chat_models.dart';

import '../utils/chunked_string_buffer.dart';

class InputParser {
  static Map<String, dynamic> targetXMLs = {
    'error': (b, content) {
      return ChatResponse(type: MessageChunkType.error, content: content);
    },
    'think': (b, content) {
      return ChatResponse(type: MessageChunkType.reasoning, content: content);
    },
  };

  _ParseState state = _ParseState.findingTagStartMark;
  String tagName = '';
  String endTagName = '';
  var blockStartPointer = 0;
  ChunkedStringBuffer parseBuffer;
  InputParser(this.parseBuffer);
  List<ChatResponse> blocksCached = [];

  /// 动态解析
  /// 从缓冲区中直接解析，无需输入内容
  ///
  // md 现在搬过来，本来因为他是针对block设计的，我本来想要继续优化的，结果发现我已经完全看不懂当时我自己写的代码了
  // 这个代码已经写的不知天地为何物了…… 改天再慢慢研究，顺便：如下
  //TODO: Upgrade the parser to enable it to resolve nested xml tags
  List<ChatResponse> parseDynamicBlock() {
    //这里分为三个步骤，第一个是已经固化的内容，这部分只存在于blocks cached中
    //第二是buffer，这里是所有没有固化的内容
    //第三是tmp buffer 这里每次都会重创建，然后内部通过消费缓冲区的内容，生成block
    //例如第二个缓冲中假如有了 <UIQ ,此时第三个缓冲区会先消费掉所有的内容生成一个文本块
    //这就是三个buffer的意义
    List<ChatResponse> blocks = [];
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
                ChatResponse(type: MessageChunkType.text,content: tmpBuffer.toString()),
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
                  ChatResponse(
                    type: MessageChunkType.text,
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
               ChatResponse(type: MessageChunkType.text,content: tmpBuffer.toString()),
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
    return blocks;
  }
}

enum _ParseState {
  findingTagStartMark,
  inStartTag,
  matchingEndTagMark,
  matchingEndTag,
}
