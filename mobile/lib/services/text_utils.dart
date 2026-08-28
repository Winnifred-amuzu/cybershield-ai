import 'dart:math' as math;

class TextUtils {
  const TextUtils._();

  /// Cleans and normalizes text for display or processing.
  static String cleanText(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Returns a shortened preview of [text].
  ///
  /// Both [max] and [maxLength] are supported for compatibility
  /// with different parts of the application.
  static String preview(
    String text, {
    int max = 120,
    int? maxLength,
  }) {
    final int effectiveMax = maxLength ?? max;
    final String cleaned = cleanText(text);

    if (cleaned.isEmpty || effectiveMax <= 0) {
      return '';
    }

    if (cleaned.length <= effectiveMax) {
      return cleaned;
    }

    if (effectiveMax <= 3) {
      return cleaned.substring(
        0,
        math.min(effectiveMax, cleaned.length),
      );
    }

    return '${cleaned.substring(0, effectiveMax - 3).trimRight()}...';
  }

  /// Extracts HTTP, HTTPS and www URLs from text.
  static List<String> extractUrls(String text) {
    final RegExp pattern = RegExp(
      r'''(?:https?://|www\.)[^\s<>"']+''',
      caseSensitive: false,
    );

    return pattern
        .allMatches(text)
        .map((match) => match.group(0) ?? '')
        .map(_cleanUrl)
        .where((url) => url.isNotEmpty)
        .toList();
  }

  /// Returns true when the supplied text contains a URL.
  static bool containsUrl(String text) {
    return extractUrls(text).isNotEmpty;
  }

  /// Cleans common Flutter/API exception prefixes.
  static String cleanError(Object error) {
    String message = error.toString().trim();

    if (message.startsWith('Exception:')) {
      message = message
          .substring('Exception:'.length)
          .trim();
    }

    if (message.startsWith('ApiException:')) {
      message = message
          .substring('ApiException:'.length)
          .trim();
    }

    if (message.isEmpty) {
      return 'Something went wrong. Please try again.';
    }

    return message;
  }

  /// Formats a decimal confidence/probability as a percentage.
  ///
  /// Example:
  ///     0.934 -> 93.4%
  static String formatPercent(
    double value, {
    int decimals = 1,
  }) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  /// Formats a confidence value as a percentage.
  static String formatConfidence(
    double value, {
    int decimals = 1,
  }) {
    return formatPercent(
      value,
      decimals: decimals,
    );
  }

  /// Normalizes whitespace without changing the actual words.
  static String normalize(String text) {
    return cleanText(text);
  }

  /// Removes punctuation that commonly appears immediately after URLs.
  static String _cleanUrl(String url) {
    return url.replaceFirst(
      RegExp(r'[.,!?;:)]+$'),
      '',
    );
  }
}