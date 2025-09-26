enum ParseState {
  expectTopLevelCmd,
  expectIdentifierEnd,
  expectAS,
  expectSET,
  expectSETOrSemicolon,
  expectWITH, //with是dart的关键词冲突了，只能大写了
  expectExecute,
  expectFunctionIdentifier,
  expectEqual,
  expectCommaOrSemicolon,
  expectParamNameOrSemicolon,
  expectParamValue,
  expectBindPromptString,
}

enum TokenType {
  // 关键字
  create,
  update,
  drop,
  bind,
  clear,
  select,
  execute,
  as,
  set,
  WITH,
  // 标识符
  identifier,
  value,

  // 操作符和分隔符
  equals,
  comma,
  semicolon,
  // 空白符
  whitespace,
  illegal,
}

class Token {
  final TokenType type;
  final String raw; // 匹配到的原始文本

  Token(this.type, this.raw);
}

class InlineDynamicParser {
  void Function(String, String, Map<String, String>?) create;
  void Function(String, Map<String, String>?) update;
  void Function(List<String>) drop;
  void Function(String, String) bind;
  void Function() clear;
  void Function(String, String, Map<String, String>) select;
  InlineDynamicParser({
    required this.create,
    required this.update,
    required this.drop,
    required this.bind,
    required this.clear,
    required this.select,
  });

  void clearAndExecute() {
    if (topLevelInstruction == null) return;
    state = ParseState.expectTopLevelCmd;
    switch (topLevelInstruction) {
      case TokenType.create:
        if (actionPanelType == null) return;
        create(topLevelIdentifier!, actionPanelType!, params);
        break;
      case TokenType.update:
        update(topLevelIdentifier!, params);
        break;
      case TokenType.drop:
        drop([topLevelIdentifier!]);
        break;
      case TokenType.bind:
        if (bindPrompt == null) return;
        bind(topLevelIdentifier!, bindPrompt!);
        break;
      case TokenType.clear:
        clear();
        break;
      case TokenType.select:
        if (functionIdentifier == null) return;
        select(topLevelIdentifier!, functionIdentifier!, params);
        break;
      default:
        break;
    }
    cleanUp();
  }

  void justExecute() {
    if (topLevelInstruction == null) return;
    switch (topLevelInstruction) {
      case TokenType.create:
        create(topLevelIdentifier!, actionPanelType!, params);
        break;
      case TokenType.update:
        update(topLevelIdentifier!, params);
        break;
      case TokenType.drop:
        drop([topLevelIdentifier!]);
        break;
      case TokenType.select:
        //select只有在clear and execute的时候才执行
        return;
      default:
        throw Exception("Invalid top level instruction");
    }
  }

  final Map<TokenType, RegExp> _tokenPatterns = {
    // 关键字 (必须完全匹配)
    TokenType.create: RegExp(r'^\bCREATE\b$', caseSensitive: false),
    TokenType.update: RegExp(r'^\bUPDATE\b$', caseSensitive: false),
    TokenType.drop: RegExp(r'^\bDROP\b$', caseSensitive: false),
    TokenType.bind: RegExp(r'^\bBIND\b$', caseSensitive: false),
    TokenType.clear: RegExp(r'^\bCLEAR\b$', caseSensitive: false),
    TokenType.select: RegExp(r'^\bSELECT\b$', caseSensitive: false),
    TokenType.as: RegExp(r'^\bAS\b$', caseSensitive: false),
    TokenType.set: RegExp(r'^\bSET\b$', caseSensitive: false),
    TokenType.WITH: RegExp(r'^\bWITH\b$', caseSensitive: false),
    TokenType.execute: RegExp(r'^\bEXECUTE\b$', caseSensitive: false),

    // 标识符 (必须完全匹配)
    TokenType.identifier: RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$'),
    // 注意: illegal, whitespace, 和操作符 (= , ;) 不再需要在这里定义
  };

  ParseState state = ParseState.expectTopLevelCmd;
  String _buffer = "";

  //下面是指令的临时储存
  TokenType? topLevelInstruction;
  String? actionPanelType;
  String? topLevelIdentifier;
  String? bindPrompt;
  String? functionIdentifier;
  Map<String, String> params = {};
  String? paramExpectToWriteValue;

  void cleanUp() {
    state = ParseState.expectTopLevelCmd;
    _inStreamingString = false;
    _isEscapingChar = false;
    topLevelInstruction = null;
    actionPanelType = null;
    topLevelIdentifier = null;
    bindPrompt = null;
    functionIdentifier = null;
    params = {};
    paramExpectToWriteValue = null;
  }

  ///这个是为了我们的debug测试器设计的，普通的不需要，测试器需要连着buffer清
  void cleanUpWithBuffer() {
    cleanUp();
    _inUIQL = false;
    _buffer = "";
    _chunkBuffer = "";
  }

  // --- 新增的类成员 ---
  bool _inUIQL = false;
  bool _isEscapingChar = false;

  // --- FSM状态追踪 ---
  // 0 = 初始状态
  // 1 = 匹配了 '<'
  // 2 = 匹配了 '</'
  // ...以此类推
  int _endTagMatchState = 0;
  final String _endTag = '</UIQL>';

  void _resetEndTagMatch() {
    _endTagMatchState = 0;
  }

  //你看着都是gemini写的，实际上我跟教孩子一样，不停的让他改，
  //Gemini 2.5 pro本身写的代码肯定没语法bug，但是对于各种边界条件和极端条件的处理还是考虑不周到
  //然后就是复杂逻辑和各种绕来绕去的东西他还是不行的，这个必须人工上来改
  //不得不说，看着他终于给我改出基本完美的代码，我都能露出姨母笑了（乐）
  // 一个更智能的、基于FSM的缓冲区处理器
  void _processUIQLContent() {
    int scanIndex = 0; // 当前扫描到缓冲区的位置
    int lastConsumeIndex = 0; // 上一次可以安全消费的位置

    while (scanIndex < _buffer.length) {
      final char = _buffer[scanIndex];
      final expectedChar = _endTag[_endTagMatchState];

      if (char == expectedChar) {
        // 字符匹配成功，状态前进
        _endTagMatchState++;
        if (_endTagMatchState == _endTag.length) {
          // --- 完整匹配到了 '</UIQL>' ---

          // 1. 解析标签之前的所有安全代码
          final tagStartIndex = scanIndex - _endTag.length + 1;
          final codeToParse = _buffer.substring(
            lastConsumeIndex,
            tagStartIndex,
          );
          if (codeToParse.isNotEmpty) {
            _parseChunk(codeToParse);
          }

          // 2. 清理和退出UIQL模式
          if (state != ParseState.expectTopLevelCmd) {
            clearAndExecute();
          }
          _inUIQL = false;
          state = ParseState.expectTopLevelCmd;
          _resetEndTagMatch();

          // 3. 丢弃已处理的代码和标签，并从循环中退出，让外层循环接管
          _buffer = _buffer.substring(scanIndex + 1);
          return; // 已找到标签，此轮处理结束
        }
      } else if (char == _endTag[0] /* a new '<' */ ) {
        // 匹配失败，但当前字符是一个新的'<'，可能是新标签的开始
        // 把之前尝试匹配的内容（如果存在）视为普通代码
        _resetEndTagMatch();
        _endTagMatchState = 1; // 直接进入状态1
      } else {
        // 匹配彻底失败，重置状态
        _resetEndTagMatch();
      }
      scanIndex++;
    }

    // --- 循环结束，仍未找到完整标签 ---
    // 我们需要决定可以安全消费多少缓冲区内容

    if (_endTagMatchState > 0) {
      // 缓冲区末尾是一个不完整的标签，比如 "... code ... </UI"
      // 我们只能安全地消费到这个不完整标签开始之前的部分
      final potentialTagStartIndex = _buffer.length - _endTagMatchState;
      final parsableChunk = _buffer.substring(
        lastConsumeIndex,
        potentialTagStartIndex,
      );
      if (parsableChunk.isNotEmpty) {
        _parseChunk(parsableChunk);
      }
      // 保留不完整的标签部分在缓冲区
      _buffer = _buffer.substring(potentialTagStartIndex);
    } else {
      // 缓冲区里没有任何潜在的标签部分，全部都是安全代码
      _parseChunk(_buffer);
      _buffer = "";
    }
  }

  ///解析器入口，传入增量块就好了，如果想要全量解析，记得调用clear with buffer来完全重置
  bool parse(String textChunk) {
    _buffer += textChunk;

    while (true) {
      if (!_inUIQL) {
        // 状态 A 的逻辑保持不变，因为它很简单且高效
        final startIndex = _buffer.indexOf('<UIQL>');
        if (startIndex != -1) {
          _inUIQL = true;
          _buffer = _buffer.substring(startIndex + '<UIQL>'.length);
          _resetEndTagMatch(); // 进入UIQL模式前重置结束标签匹配状态
          continue;
        } else {
          final lastLtIndex = _buffer.lastIndexOf('<');
          if (lastLtIndex != -1) {
            _buffer = _buffer.substring(lastLtIndex);
          } else {
            _buffer = "";
          }
          break;
        }
      } else {
        // --- 状态 B: 使用FSM处理器 ---
        final bufferBeforeProcessing = _buffer;

        _processUIQLContent();

        // 如果处理器没有消费任何数据（因为缓冲区太短，可能是不完整标签），
        // 并且我们还在UIQL模式中，就跳出循环等待更多数据。
        if (_inUIQL && _buffer == bufferBeforeProcessing) {
          break;
        }

        // 如果退出了UIQL模式，就继续外层循环，可能立即找到下一个<UIQL>
        // 如果还在UIQL模式但消费了数据，也继续，因为可能还有更多数据要处理
        if (!_inUIQL) {
          continue;
        } else {
          // 如果还在UIQL模式，说明已经处理完当前所有安全数据，等待下一个chunk
          break;
        }
      }
    }
    return _inUIQL;
  }

  String _chunkBuffer = '';

  /// 内部解析逻辑，原 parse 方法的核心被移到这里
  void _parseChunk(String chunk) {
    _chunkBuffer += chunk;

    // 只要能成功解析出token，就一直循环
    while (true) {
      if (_chunkBuffer.isEmpty) break;

      Token? token;
      // 关键：根据当前状态决定如何分词
      if (state == ParseState.expectParamValue) {
        token = _parseValue();
      } else if (state == ParseState.expectBindPromptString) {
        // <--- 新增分支
        token = _parseBindPrompt();
      } else {
        token = _nextToken();
      }

      if (token != null) {
        tokenParser(token);
      } else {
        // 如果无法解析出完整token，则中断循环，等待更多数据
        break;
      }
    }
  }

  Token? _nextToken() {
    // 步骤 1: 消耗掉所有前导的空白符。它们只是分隔物。
    _chunkBuffer = _chunkBuffer.trimLeft();
    if (_chunkBuffer.isEmpty) {
      return null;
    }

    // 步骤 2: 优先处理单字符的Token。它们本身就是最简单的词法单元。
    final String firstChar = _chunkBuffer[0];
    if (firstChar == '=') {
      _chunkBuffer = _chunkBuffer.substring(1);
      return Token(TokenType.equals, '=');
    }
    if (firstChar == ',') {
      _chunkBuffer = _chunkBuffer.substring(1);
      return Token(TokenType.comma, ',');
    }
    if (firstChar == ';') {
      _chunkBuffer = _chunkBuffer.substring(1);
      return Token(TokenType.semicolon, ';');
    }

    // 步骤 3: 寻找下一个边界，以切分出一个完整的“单词”。
    // 边界可以是一个空白符，也可以是任何一个分隔符。
    final boundaryRegex = RegExp(r'[\s=,;]');
    int boundaryIndex = -1;
    final match = boundaryRegex.firstMatch(_chunkBuffer);
    if (match != null) {
      boundaryIndex = match.start;
    }

    if (boundaryIndex == -1) {
      // 在当前缓冲区中没有找到任何边界。
      // 这意味着当前的词法单元可能还不完整（例如，流只发送了 "CREA"）。
      // 我们必须返回 null，等待更多的数据进来。
      return null;
    }

    // 步骤 4: 找到了边界。我们现在有了一个完整的词法单元 (lexeme)。
    final lexeme = _chunkBuffer.substring(0, boundaryIndex);
    // 从缓冲区中消耗掉这个词法单元，准备下一次解析。
    // 注意：边界字符本身（如空格）没有被消耗，它将在下一次调用开始时被 trimLeft() 清理掉。
    _chunkBuffer = _chunkBuffer.substring(boundaryIndex);

    // 这种情况可能在缓冲区是 "=abc" 时发生，上面的单字符处理会处理掉 "="
    // 剩下的 "abc" 会在这里被正确解析。但如果缓冲区是 "  =abc"
    // trimLeft 之后，lexeme 可能会是空，需要递归处理一下。
    if (lexeme.isEmpty) {
      return _nextToken();
    }

    // 步骤 5: 用我们的模式字典去识别这个完整的 lexeme。
    for (var entry in _tokenPatterns.entries) {
      if (entry.value.hasMatch(lexeme)) {
        // 匹配成功，返回对应的 Token。
        return Token(entry.key, lexeme);
      }
    }

    // 步骤 6: 如果所有合法的模式都匹配失败了，
    // 那么这个完整的词法单元就是非法的（illegal）。
    return Token(TokenType.illegal, lexeme);
  }

  bool _inStreamingString = false; // <--- 新增状态，追踪是否在流式字符串内部
  Token? _parseValue() {
    _chunkBuffer = _chunkBuffer.trimLeft();
    if (_chunkBuffer.isEmpty) return null;

    // --- Case 1: 进入或继续流式字符串 ---
    // 如果我们已经在一个字符串里，或者将要开始一个新的字符串
    if (_inStreamingString || _chunkBuffer.startsWith('"')) {
      // 如果是刚开始，消耗掉开头的引号，并设置状态
      if (!_inStreamingString) {
        _chunkBuffer = _chunkBuffer.substring(1);
        _inStreamingString = true;
      }

      final valueBuffer = StringBuffer();
      int i = 0;
      bool foundEndQuote = false;

      while (i < _chunkBuffer.length) {
        final char = _chunkBuffer[i];

        if (_isEscapingChar) {
          // --- FIX 1: Correctly handle escape sequences ---
          switch (char) {
            case 'n':
              valueBuffer.write('\n'); // 写入真正的换行符
              break;
            case 't':
              valueBuffer.write('\t'); // 写入真正的制表符
              break;
            case 'r':
              valueBuffer.write('\r'); // 写入回车符
              break;
            case '"':
              valueBuffer.write('"'); // 写入双引号
              break;
            case '\\':
              valueBuffer.write('\\'); // 写入反斜杠
              break;
            default:
              // 对于未知的转义序列，可以选择直接写入，或者报错
              // 这里我们选择保留原始字符，例如 \x 会被写入为 x
              valueBuffer.write(char);
              break;
          }
          _isEscapingChar = false;
        } else {
          if (char == '\\') {
            _isEscapingChar = true;
          } else if (char == '"') {
            // 找到了字符串的结尾
            foundEndQuote = true;
            break; // 结束循环
          } else {
            valueBuffer.write(char);
          }
        }
        i++;
      }

      // --- 更新逻辑 ---
      final content = valueBuffer.toString();

      // 无论是否找到结尾，只要有内容就先执行动态更新
      if (paramExpectToWriteValue != null && content.isNotEmpty) {
        params[paramExpectToWriteValue!] =
            (params[paramExpectToWriteValue!] ?? "") + content;
        justExecute();
      }
      if (foundEndQuote) {
        // 找到了结尾，说明这个 value token 完整了
        final finalValue = params[paramExpectToWriteValue!] ?? "";

        // 重置状态
        _inStreamingString = false;
        _isEscapingChar = false;

        // 消耗掉已处理的内容 和 结尾的引号
        _chunkBuffer = _chunkBuffer.substring(i + 1);

        return Token(TokenType.value, finalValue);
      } else {
        // 没找到结尾，说明字符串还没完
        // 只消耗掉当前已处理的所有内容
        _chunkBuffer = "";
        // 返回 null，等待更多数据
        return null;
      }
    }

    // --- Case 2: JSON 对象或数组 (逻辑不变) ---
    if (_chunkBuffer.startsWith('{') || _chunkBuffer.startsWith('[')) {
      return _parseJsonValue();
    }

    // --- Case 3: 原子值 (如数字, 布尔值) (逻辑不变) ---
    final commaIndex = _chunkBuffer.indexOf(',');
    final semicolonIndex = _chunkBuffer.indexOf(';');

    int endIndex = -1;
    if (commaIndex != -1 && semicolonIndex != -1) {
      endIndex = commaIndex < semicolonIndex ? commaIndex : semicolonIndex;
    } else {
      endIndex = commaIndex != -1 ? commaIndex : semicolonIndex;
    }

    if (endIndex != -1) {
      final value = _chunkBuffer.substring(0, endIndex).trim();
      _chunkBuffer = _chunkBuffer.substring(endIndex);
      return Token(TokenType.value, value);
    }

    return null;
  }

  /// 解析一个完整的 JSON 对象或数组值。
  /// 它通过括号计数来确保值的完整性，同时会正确处理内部的字符串。
  /// 如果缓冲区中的 JSON/数组不完整，则返回 null，等待更多数据。
  Token? _parseJsonValue() {
    int braceCount = 0; // 花括号 {} 计数器
    int bracketCount = 0; // 方括号 [] 计数器
    bool inString = false;
    bool isEscaping = false;

    // 逐字符扫描缓冲区
    for (int i = 0; i < _chunkBuffer.length; i++) {
      final char = _chunkBuffer[i];

      if (isEscaping) {
        // 上一个字符是'\'，本次直接跳过，并重置转义状态
        isEscaping = false;
        continue;
      }

      if (char == '\\') {
        isEscaping = true;
        continue;
      }

      // 如果遇到非转义的引号，切换字符串状态
      if (char == '"') {
        inString = !inString;
      }

      // 只有在字符串外部时，才进行括号计数
      if (!inString) {
        switch (char) {
          case '{':
            braceCount++;
            break;
          case '}':
            braceCount--;
            break;
          case '[':
            bracketCount++;
            break;
          case ']':
            bracketCount--;
            break;
        }
      }

      // 检查是否一个完整的 JSON 单元已经形成
      // 条件：所有括号都已闭合，且我们至少处理了一个字符
      // （起始的括号必须被计入）
      if (braceCount == 0 &&
          bracketCount == 0 &&
          (i > 0 ||
              (_chunkBuffer.length > 1 &&
                  (_chunkBuffer[0] == '{' || _chunkBuffer[0] == '[')))) {
        // 找到了一个完整的 JSON 值
        final value = _chunkBuffer.substring(0, i + 1);
        _chunkBuffer = _chunkBuffer.substring(i + 1);
        // 重置父解析器的转义状态，以防万一
        _isEscapingChar = false;
        return Token(TokenType.value, value);
      }
    }

    // 如果扫描完整个缓冲区，括号仍未平衡，说明 JSON 不完整
    // 返回 null，等待更多的数据流
    return null;
  }

  /// 专门用于解析 BIND 命令后的提示词字符串。
  /// 它需要一个完整的、被双引号包裹的字符串。
  /// 如果字符串不完整，则返回 null 等待更多数据。
  Token? _parseBindPrompt() {
    _chunkBuffer = _chunkBuffer.trimLeft();
    if (_chunkBuffer.isEmpty || !_chunkBuffer.startsWith('"')) {
      // BIND 的 prompt 必须以 " 开头，否则是语法错误
      // 但因为数据可能不完整，暂时不报错，返回 null 等待
      return null;
    }

    bool isEscaping = false;
    // 从第二个字符开始寻找结束的引号
    for (int i = 1; i < _chunkBuffer.length; i++) {
      final char = _chunkBuffer[i];
      if (isEscaping) {
        isEscaping = false;
        continue;
      }

      if (char == '\\') {
        isEscaping = true;
        continue;
      }

      if (char == '"') {
        // 找到了结束的引号
        // 提取引号之间的内容 (不包括引号本身)
        final value = _chunkBuffer.substring(1, i);
        // 消耗掉整个带引号的字符串
        _chunkBuffer = _chunkBuffer.substring(i + 1);
        _isEscapingChar = false; // 确保状态被重置
        return Token(TokenType.value, value);
      }
    }

    // 扫描完缓冲区还没找到结束的引号，说明字符串不完整
    return null;
  }

  void tokenParser(Token token) {
    if (token.type == TokenType.illegal) {
      throw Exception('Invalid token: ${token.raw}');
      // 直接终止，不进入任何状态
    }
    switch (state) {
      case ParseState.expectTopLevelCmd:
        if (token.type == TokenType.create ||
            token.type == TokenType.drop ||
            token.type == TokenType.update ||
            token.type == TokenType.bind ||
            token.type == TokenType.select) {
          state = ParseState.expectIdentifierEnd;
          topLevelInstruction = token.type;
        } else if (token.type == TokenType.clear) {
          clearAndExecute();
        } else if (token.type == TokenType.semicolon) {
          return;
          //是的，实际上分号甚至能够当作缩进来使用，所以遇到单独一个分号不是什么错误
        } else {
          throw Exception(
            "Unexpected token ${token.type} token should be one of [update, bind, select, clear,create,drop]",
          );
        }
        break;
      case ParseState.expectIdentifierEnd:
        if (token.type == TokenType.identifier) {
          switch (topLevelInstruction) {
            case TokenType.create:
              if (topLevelIdentifier != null) {
                state = ParseState.expectSETOrSemicolon;
                actionPanelType = token.raw;
              } else {
                topLevelIdentifier = token.raw;
                state = ParseState.expectAS;
              }
              break;
            case TokenType.drop:
              topLevelIdentifier = token.raw;
              state = ParseState.expectCommaOrSemicolon;
              break;
            case TokenType.update:
              topLevelIdentifier = token.raw;
              state = ParseState.expectSET;
              break;
            case TokenType.bind:
              topLevelIdentifier = token.raw;
              state = ParseState.expectWITH;
              break;
            case TokenType.select:
              topLevelIdentifier = token.raw;
              state = ParseState.expectExecute;
              break;
            default:
              throw Exception('Unexpected condition');
          }
        } else {
          throw Exception('Unexpected token , should be identifier');
        }
        break;
      case ParseState.expectExecute:
        if (token.type == TokenType.execute) {
          state = ParseState.expectFunctionIdentifier;
        } else {
          throw Exception(
            'Unexpected token of type ${token.type} + ${token.raw} should be \'EXECUTE\'',
          );
        }
        break;
      case ParseState.expectFunctionIdentifier:
        if (token.type == TokenType.identifier) {
          functionIdentifier = token.raw;
          state = ParseState.expectWITH;
        } else {
          throw Exception(
            'Unexpected token of type ${token.type} + ${token.raw} should be an identifier',
          );
        }
        break;
      case ParseState.expectAS:
        if (token.type == TokenType.as) {
          state = ParseState.expectIdentifierEnd;
        } else {
          throw Exception(
            'Unexpected token of type ${token.type} + ${token.raw}, should be \'AS\'',
          );
        }
        break;
      case ParseState.expectSET:
        if (token.type == TokenType.set) {
          state = ParseState.expectParamNameOrSemicolon;
        } else {
          ///tmd我真的服了，可能是我测试的模型太蠢了（gemini 1.5 flash），他每次就是一定要update execute，就是不愿意select execute
          ///为此我们有了这一段擦屁股的代码 ！！这不是UIQL的标准语法，这是为了防止那些蠢蠢的模型给我整事情
          if (token.type == TokenType.execute&&topLevelInstruction == TokenType.update) {
            topLevelInstruction = TokenType.select;
            state = ParseState.expectFunctionIdentifier;
          }
          throw Exception(
            'Unexpected token of type ${token.type} + ${token.raw} should be \'SET\'',
          );
        }
        break;
      case ParseState.expectSETOrSemicolon:
        if (token.type == TokenType.set) {
          state = ParseState.expectParamNameOrSemicolon;
          justExecute();
        } else if (token.type == TokenType.semicolon) {
          clearAndExecute();
        } else {
          throw Exception(
            'Unexpected token of type ${token.type} + ${token.raw} should be \'SET\' or \';\'',
          );
        }
        break;
      case ParseState.expectWITH:
        if (token.type == TokenType.WITH) {
          if (topLevelInstruction == TokenType.bind) {
            state = ParseState.expectBindPromptString;
          } else if (topLevelInstruction == TokenType.select) {
            state = ParseState.expectParamNameOrSemicolon;
          }
        } else {
          throw Exception(
            'Unexpected token of type ${token.type} + ${token.raw} should be \'WITH\'',
          );
        }
        break;
      case ParseState.expectParamNameOrSemicolon:
        if (token.type == TokenType.identifier) {
          paramExpectToWriteValue = token.raw;
          state = ParseState.expectEqual;
        } else if (token.type == TokenType.semicolon) {
          clearAndExecute();
        } else {
          throw Exception(
            'Unexpected token of type ${token.type} + ${token.raw} should be an identifier or \';\'',
          );
        }
        break;
      case ParseState.expectEqual:
        if (token.type == TokenType.equals) {
          state = ParseState.expectParamValue;
        } else {
          throw Exception(
            'Unexpected token of type ${token.type} + ${token.raw} should be \'=\'',
          );
        }
        break;
      case ParseState.expectParamValue:
        if (token.type == TokenType.value) {
          if (paramExpectToWriteValue != null) {
            params[paramExpectToWriteValue!] = token.raw;
            paramExpectToWriteValue = null; // 清除，准备下一个参数
          } else {
            throw Exception(
              'Unexpected token of type ${token.type} + ${token.raw} should be an attribute value',
            );
          }
          justExecute(); // 完整值解析后执行一次
          state = ParseState.expectCommaOrSemicolon;
        } else {
          // 流式字符串已在 _parseValue 中处理，这里不应再收到 token
          // 如果收到了，说明逻辑有误
          throw Exception('Unexpected error');
        }
        break;
      case ParseState.expectCommaOrSemicolon:
        if (token.type == TokenType.comma) {
          if (topLevelInstruction == TokenType.bind) {
            throw Exception(
              'Unexpected token of type ${token.type} + ${token.raw} should be \';\'',
            );
          } else if (topLevelInstruction == TokenType.drop) {
            state = ParseState.expectIdentifierEnd;
            justExecute(); //这里其实算是利用bug去执行，由于他跳回了顶部，此时要删除的面板的值会被覆盖，但是他先提前执行的逻辑又很好的弥补了这一点
          } else {
            state = ParseState.expectParamNameOrSemicolon;
          }
        } else if (token.type == TokenType.semicolon) {
          clearAndExecute();
        } else {
          throw Exception(
            'Unexpected token: ${token.type},should be semicolon or comma',
          );
        }
        break;
      case ParseState.expectBindPromptString:
        if (token.type == TokenType.value) {
          // 从 _parseBindPrompt 获得了完整的 prompt
          bindPrompt = token.raw;
          // 接下来只可能是一个分号
          state = ParseState.expectCommaOrSemicolon;
        } else {
          throw Exception("Expect an value, but got ${token.type}");
        }
        break;
    }
  }
}
