# Localization Guide

## Supported Languages

Our project currently supports the following languages:
- English (en)
- Simplified Chinese (zh)
- Traditional Chinese (zh_TW)

As a general principle, all contributions should include localization. If you're unable to provide translations, please mark this in your pull request, and the author will assist with localization. Please avoid using AI or Google Translate for this purpose.

## Adding New Languages

If you'd like to contribute translations for a new language:
1. Create an issue proposing the new language
2. Create a new branch for your translation work

## Implementation Guidelines

This project uses the Flutter Intl plugin, available for both VSCode and IntelliJ IDEA. Install this plugin before proceeding with localization.

### Step 1: Add String Keys to ARB Files

The main ARB file is located at `lib/l10n/intl_en.arb`. When you add new key-value pairs to this file and save it, those keys will automatically be available for auto-completion in your Dart code.

For other languages, add corresponding key-value pairs in their respective ARB files:
- Simplified Chinese: `lib/l10n/intl_zh.arb`
- Traditional Chinese: `lib/l10n/intl_zh_TW.arb`

To add a completely new language:
1. Use the "Add Locale" option in the Flutter Intl plugin menu (for IntelliJ it's located in the "Tools" menu)
2. Add key-value pairs to the newly created ARB file

#### Example ARB File Content

```json
{
  "title": "Hello World!"
}
```

An ARB file is essentially a JSON file with specific conventions.

### Step 2: Reference Keys in Dart Code

The ARB file keys correspond to methods in the S class. Here's how to use them:

```dart
Widget build(BuildContext context) {
  return Text(S.of(context).title);
}
```

## Placeholders

Placeholders are marked with curly brackets. The variable name inside `{}` must be a valid identifier, such as `{firstName}`.

### Basic Placeholder Example

```json
"memberSince": "Joined on {yr}-{mon}-{day}",
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

Usage in Flutter:

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

### Advanced Placeholder Types

Placeholders support various data types: String, Object, int, double, num, and DateTime.

#### Numeric Placeholders

For int, double, and num types, you can specify optional formatting parameters:

| Format | Available Parameters | Example Output for "1200000" |
|--------|---------------------|------------------------------|
| compact | - | "1.2M" |
| compactCurrency | name, symbol, decimalDigits | "$1.2M" |
| compactSimpleCurrency | name, decimalDigits | "$1.2M" |
| compactLong | - | "1.2 million" |
| currency | name, symbol, decimalDigits, customPattern | "$1200000.00" |
| decimalPattern | - | "1,200,000" |
| decimalPatternDigits | decimalDigits | "1,200,000.00" |
| decimalPercentPattern | decimalDigits | "120,000,000.00%" |
| percentPattern | - | "120,000,000%" |
| scientificPattern | - | "1E6" |
| simpleCurrency | name, decimalDigits | "$1,200,000.00" |

#### DateTime Placeholders

DateTime placeholders offer predefined format options like yMd and Hms, derived from the DateFormat class constructors.

##### Custom Date Formats

```json
"commonCustomDateFormat": "Custom date format: {date}",
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

##### Multiple Date Formats

You can combine multiple formats using "+":

```json
"commonMultipleDateFormats": "Custom date format: {date}",
"@commonMultipleDateFormats": {
  "placeholders": {
    "date": {
      "type": "DateTime",
      "format": "yMEd+Hm"
    }
  }
}
```

##### ICU Message Format

For cross-file consistency, use ICU Message Format syntax:

```json
"commonInlineDateFormat": "Date format: {currDate, date, ::yMd}",
"@commonInlineDateFormat": {
  "placeholders": {
    "currDate": {}
  }
}
```

## Special Characters

In some cases, you may need to treat special characters like `{` and `}` as literal text. With the gen-l10n tool, enclose the relevant section in single quotes and enable escaping by setting `use-escaping` to true in your `l10n.yaml` file.

```json
"escapingExample": "In math, '{1, 2, 3}' denotes a set."
```

## HTML Tags

HTML tags can be used in localization messages to avoid splitting messages for styling purposes:

```json
"htmlExample": "<i>Discover <b>Flutter</b></i>"
```