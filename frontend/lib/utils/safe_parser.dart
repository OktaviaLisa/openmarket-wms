class SafeParser {
  static int parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return defaultValue;
      // Extract only digits from mixed text (e.g., "50 ton" -> "50")
      final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
      if (digitsOnly.isEmpty) return defaultValue;
      return int.tryParse(digitsOnly) ?? defaultValue;
    }
    return defaultValue;
  }

  static String parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  static bool isValidInt(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final digitsOnly = value.trim().replaceAll(RegExp(r'[^0-9]'), '');
    return digitsOnly.isNotEmpty && int.tryParse(digitsOnly) != null;
  }

  static String extractDigits(String? value) {
    if (value == null) return '';
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }
}