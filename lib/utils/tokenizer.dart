class LLMTokenEstimator {
  // LLM Token 估算比例常量 (基于经验法则)
  // ----------------------------------------------------
  // 英文：约 4 个字符 (char) 对应 1 个 token。
  static const double _englishCharsPerToken = 4.0;

  // 中文：约 1.5 到 2 个汉字 (char) 对应 1 个 token。
  // 我们取一个保守值 1.8 个汉字/token，即 0.55 token/汉字。
  static const double _chineseCharsPerToken = 1.8;

  // 正则表达式：用于匹配大部分中文字符（Unicode 范围）。
  // CJK Unified Ideographs (4E00-9FFF) 及其扩展。
  static final RegExp _chineseRegExp = RegExp(r'[\u4E00-\u9FFF]');

  /// 估算给定文本的 Token 数量。
  /// 
  /// 算法：
  /// 1. 将文本分成中文部分和非中文部分（主要为英文和标点）。
  /// 2. 分别应用不同的 Token 估算比例。
  /// 3. 将两者加和，并向上取整。
  static int estimateTokens(String text) {
    if (text.isEmpty) {
      return 0;
    }

    // 1. 分离中文字符和非中文字符
    final chineseMatches = _chineseRegExp.allMatches(text);

    // 提取中文部分字符数
    int chineseCharCount = chineseMatches.length;

    // 非中文部分（视为英文、数字、标点等）
    // 简单的做法是总长度减去中文字符数。
    // 注意：Dart 的 length 属性返回的是 UTF-16 code unit 数量，对于 ASCII 字符和汉字通常是准确的字符数。
    int otherCharCount = text.length - chineseCharCount;

    // 2. 分别应用估算比例计算 Token 数

    // 中文 Token 估算
    // token = 字符数 / 1.8 (1.8个汉字/token)
    double chineseTokens = chineseCharCount / _chineseCharsPerToken;

    // 英文/其他 Token 估算
    // token = 字符数 / 4.0 (4个字符/token)
    // 这里的 'other' 包括了所有非汉字部分，用英文的比例来估算是一种常用的粗略方法。
    double otherTokens = otherCharCount / _englishCharsPerToken;

    // 3. 总和并向上取整 (因为 token 必须是整数)
    double totalTokens = chineseTokens + otherTokens;

    // 使用 ceil() 确保结果是向上取整的最小整数
    return totalTokens.ceil();
  }
}
