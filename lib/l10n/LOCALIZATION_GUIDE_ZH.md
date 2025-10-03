# 本地化指南

## 支持的语言

本项目目前支持以下语言：
- 英语 (en)
- 简体中文 (zh)
- 繁体中文 (zh_TW)

原则上，所有贡献都应包含本地化内容。如果您无法提供翻译，请在 Pull Request 中注明，作者将协助完成本地化。请勿使用 AI 或谷歌翻译草率处理。

## 添加新语言

如果您想为新语言贡献翻译：
1. 创建一个 Issue 提议添加新语言
2. 创建新分支进行翻译工作

## 实现指南

本项目使用 Flutter Intl 插件，该插件支持 VSCode 和 IntelliJ IDEA。在进行本地化之前请先安装此插件。

### 步骤 1：在 ARB 文件中添加字符串键值对

主 ARB 文件位于 `lib/l10n/intl_en.arb`。当您向该文件添加新的键值对并保存时，这些键将自动在 Dart 代码中支持自动补全。

对于其他语言，请在相应的 ARB 文件中添加对应的键值对：
- 简体中文: `lib/l10n/intl_zh.arb`
- 繁体中文: `lib/l10n/intl_zh_TW.arb`

添加全新语言的步骤：
1. 在 Flutter Intl 插件菜单（在idea中，这位于Tools栏）中使用 "Add Locale" 选项
2. 在新创建的 ARB 文件中添加键值对

#### ARB 文件内容示例

```json
{
  "title": "你好，世界！"
}
```

ARB 文件本质上是一个具有特定约定的 JSON 文件。

### 步骤 2：在 Dart 代码中引用键值

ARB 文件中的键对应于 S 类中的方法。使用方式如下：

```dart
Widget build(BuildContext context) {
  return Text(S.of(context).title);
}
```

## 占位符

占位符使用花括号标记。花括号内的变量名 `{}` 必须是有效的标识符，例如 `{firstName}`。

### 基本占位符示例

```json
"memberSince": "{yr}年{mon}月{day}日加入",
"@memberSince": {
  "placeholders": {
    "yr": {
      "type": "int",
      "example": "2024"
    },
    "mon": {
      "type": "int",
      "example": "01"
    },
    "day": {
      "type": "int",
      "example": "01"
    }
  }
}
```

在 Flutter 中的用法：

```dart
Text(
  S.of(context).memberSince(
    userViewModel.user!.createdAt.year,
    userViewModel.user!.createdAt.month,
    userViewModel.user!.createdAt.day),
  style: TextStyle(
    fontSize: 12.0,
    fontFamily: "SmileySans",
    color: Colors.grey[600],
  ),
)
```

### 高级占位符类型

占位符支持多种数据类型：String、Object、int、double、num 和 DateTime。

#### 数字占位符

对于 int、double 和 num 类型，可以指定可选的格式参数：

| 格式 | 可用参数 | "1200000" 的示例输出 |
|------|---------|-------------------|
| compact | - | "1.2M" |
| compactCurrency | name, symbol, decimalDigits | "$1.2M" |
| compactSimpleCurrency | name, decimalDigits | "$1.2M" |
| compactLong | - | "1.2 百万" |
| currency | name, symbol, decimalDigits, customPattern | "$1200000.00" |
| decimalPattern | - | "1,200,000" |
| decimalPatternDigits | decimalDigits | "1,200,000.00" |
| decimalPercentPattern | decimalDigits | "120,000,000.00%" |
| percentPattern | - | "120,000,000%" |
| scientificPattern | - | "1E6" |
| simpleCurrency | name, decimalDigits | "$1,200,000.00" |

#### 日期时间占位符

DateTime 占位符提供了预定义的格式选项，如 yMd 和 Hms，这些选项源自 DateFormat 类构造函数。

##### 自定义日期格式

```json
"commonCustomDateFormat": "自定义日期格式: {date}",
"@commonCustomDateFormat": {
  "placeholders": {
    "date": {
      "type": "DateTime",
      "format": "EEE, M/d/y",
      "isCustomDateFormat": "true"
    }
  }
}
```

##### 多重日期格式

可以使用 "+" 组合多种格式：

```json
"commonMultipleDateFormats": "自定义日期格式: {date}",
"@commonMultipleDateFormats": {
  "placeholders": {
    "date": {
      "type": "DateTime",
      "format": "yMEd+Hm"
    }
  }
}
```

##### ICU 消息格式

为了在不同文件间保持一致性，可以使用 ICU 消息格式语法：

```json
"commonInlineDateFormat": "日期格式: {currDate, date, ::yMd}",
"@commonInlineDateFormat": {
  "placeholders": {
    "currDate": {}
  }
}
```

## 特殊字符

在某些情况下，您可能需要将特殊字符（如 `{` 和 `}`）作为普通文本处理。使用 gen-l10n 工具时，将相关部分用单引号括起来，并在 `l10n.yaml` 文件中将 `use-escaping` 设置为 true 来启用转义机制。

```json
"escapingExample": "在数学中, '{1, 2, 3}' 表示一个集合。"
```

## HTML 标签

在本地化消息中可以使用 HTML 标签，以避免为了样式目的而将消息分割成更小的部分：

```json
"htmlExample": "<i>探索 <b>Flutter</b></i>"
```