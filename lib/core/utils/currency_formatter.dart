// lib/utils/currency_formatter.dart
class BdTakaFormatter {
  // Unicode points for Bengali digits (0-9)
  static const List<String> _bengaliDigits = [
    '০',
    '১',
    '২',
    '৩',
    '৪',
    '৫',
    '৬',
    '৭',
    '৮',
    '৯',
  ];

  /// Formats a number according to Bangladesh currency format
  /// Examples:
  /// 1000.00 -> 1,000.00
  /// 10000.00 -> 10,000.00
  /// 100000.00 -> 1,00,000.00
  /// 10000000.00 -> 1,00,00,000.00
  static String format(
    double amount, {
    int decimalPlaces = 0,
    bool toBengaliDigits = false,
  }) {
    // Convert to fixed decimal places
    String priceString = amount.toStringAsFixed(decimalPlaces);

    // Split the string into integer and decimal parts
    List<String> parts = priceString.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';

    // Format the integer part with Bangladesh-style separators
    String formattedInteger = _formatIntegerPartBangladeshStyle(integerPart);

    // Combine the formatted integer part with the decimal part
    String formattedNumber;
    if (decimalPart.isNotEmpty) {
      formattedNumber = '$formattedInteger.$decimalPart';
    } else {
      formattedNumber = formattedInteger;
    }

    // Convert to Bengali digits if requested
    if (toBengaliDigits) {
      return _convertToBengaliDigits(formattedNumber);
    }

    return formattedNumber;
  }

  /// Formats just the integer part according to Bangladesh currency format:
  /// - Last 3 digits remain as is
  /// - After that, groups of 2 digits are separated by commas
  static String _formatIntegerPartBangladeshStyle(String integerPart) {
    // If the number is less than 1000, return as is
    if (integerPart.length <= 3) {
      return integerPart;
    }

    // Extract the last 3 digits
    String lastThreeDigits = integerPart.substring(integerPart.length - 3);
    String remainingDigits = integerPart.substring(0, integerPart.length - 3);

    // Format remaining digits into groups of 2 from right to left
    String formattedRemainingDigits = '';
    for (int i = remainingDigits.length; i > 0; i -= 2) {
      int startIndex = i - 2 < 0 ? 0 : i - 2;
      String chunk = remainingDigits.substring(startIndex, i);

      if (formattedRemainingDigits.isEmpty) {
        formattedRemainingDigits = chunk;
      } else {
        formattedRemainingDigits = '$chunk,$formattedRemainingDigits';
      }
    }

    // Combine the formatted parts
    return formattedRemainingDigits.isEmpty
        ? lastThreeDigits
        : '$formattedRemainingDigits,$lastThreeDigits';
  }

  static _convertToBengaliDigits(String text) {
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

    for (int i = 0; i < englishDigits.length; i++) {
      text = text.replaceAll(englishDigits[i], bengaliDigits[i]);
    }

    return text;
  }

  // Add this utility method to convert Bengali digits to English digits
  // This is needed for processing the input as numbers
  static _convertToEnglishDigits(String text) {
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

    for (int i = 0; i < bengaliDigits.length; i++) {
      text = text.replaceAll(bengaliDigits[i], englishDigits[i]);
    }

    return text;
  }

  /// Converts an English/Western digit string to Bengali digits
  static String toBengaliDigits(String input) {
    return _convertToBengaliDigits(input);
  }

  /// Converts a number to Bengali digits
  static String numberToBengaliDigits(num number) {
    if (number == number.toInt()) {
      return _convertToBengaliDigits(number.toInt().toString());
    } else {
      return _convertToBengaliDigits(number.toString());
    }
  }

  /// Formats a number as Bangladesh Taka currency with symbol
  /// Example: 10000.50 -> ৳ 10,000.50 or ৳ ১০,০০০.৫০ if toBengaliDigits is true
  static String formatWithSymbol(
    double amount, {
    int decimalPlaces = 2,
    bool toBengaliDigits = false,
    String symbol = '৳',
  }) {
    return '$symbol ${format(amount, decimalPlaces: decimalPlaces, toBengaliDigits: toBengaliDigits)}';
  }

  /// Formats a number with the specified currency symbol
  static String formatWithCustomSymbol(
    double amount,
    String currencySymbol, {
    int decimalPlaces = 2,
    bool toBengaliDigits = false,
  }) {
    return '$currencySymbol ${format(amount, decimalPlaces: decimalPlaces, toBengaliDigits: toBengaliDigits)}';
  }
}
