import 'package:intl/intl.dart';

class TimeUtils {
  /// 将时间格式化为分钟精度，例如：2026-03-29 09:50
  /// 这有助于在 60 秒内的多次请求中保持相同的系统前缀，从而提高缓存命中率。
  static String formatTimeForCache(DateTime time) {
    return DateFormat('yyyy-MM-dd EEE HH:mm').format(time);
  }

  /// 获取与上一条消息的时间间隔描述
  /// 只有当间隔超过 1 小时时才会返回描述字符串，以避免环境信息污染。
  static String? getTimeGapDescription(
    DateTime now,
    DateTime? lastMessageTime,
  ) {
    if (lastMessageTime == null) return null;

    final difference = now.difference(lastMessageTime);

    // 如果间隔小于 1 小时，不进行描述
    if (difference.inHours < 1) return null;

    if (difference.inDays >= 1) {
      return "It has been ${difference.inDays} day(s) since the last message.";
    } else {
      return "It has been ${difference.inHours} hour(s) since the last message.";
    }
  }
}
