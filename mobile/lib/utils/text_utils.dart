class TextUtils {
  const TextUtils._();

  static String preview(String text, {int maxLength = 120}) {
    final cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (cleaned.length <= maxLength) {
      return cleaned;
    }

    return '${cleaned.substring(0, maxLength).trim()}...';
  }

  static String formatPercent(double value) {
    final percentage = value <= 1 ? value * 100 : value;
    return '${percentage.toStringAsFixed(1)}%';
  }

  static String capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() + value.substring(1);
  }
}