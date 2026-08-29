class UrlAnalysis {
  final String url;
  final bool valid;
  final String scheme;
  final String host;
  final bool isHttps;
  final bool isShortener;
  final bool hasUsername;
  final bool hasNonDefaultPort;
  final bool isLong;
  final List<String> indicators;

  const UrlAnalysis({
    required this.url,
    required this.valid,
    required this.scheme,
    required this.host,
    required this.isHttps,
    required this.isShortener,
    required this.hasUsername,
    required this.hasNonDefaultPort,
    required this.isLong,
    required this.indicators,
  });

  /// URL analysis currently reports security indicators,
  /// not an ML scam prediction.
  bool get hasWarnings => indicators.isNotEmpty;

  factory UrlAnalysis.fromJson(Map<String, dynamic> json) {
    final rawIndicators = json['indicators'] ?? const <dynamic>[];

    return UrlAnalysis(
      url: json['url']?.toString() ?? '',
      valid: _toBool(json['valid']),
      scheme: json['scheme']?.toString() ?? '',
      host: json['host']?.toString() ?? '',
      isHttps: _toBool(
        json['is_https'] ?? json['https'],
      ),
      isShortener: _toBool(
        json['is_shortener'] ?? json['shortener'],
      ),
      hasUsername: _toBool(
        json['has_username'],
      ),
      hasNonDefaultPort: _toBool(
        json['has_non_default_port'],
      ),
      isLong: _toBool(
        json['is_long'] ?? json['long_url'],
      ),
      indicators: rawIndicators is List
          ? rawIndicators
              .map((item) => item.toString())
              .where((item) => item.trim().isNotEmpty)
              .toList()
          : <String>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'valid': valid,
      'scheme': scheme,
      'host': host,
      'is_https': isHttps,
      'is_shortener': isShortener,
      'has_username': hasUsername,
      'has_non_default_port': hasNonDefaultPort,
      'is_long': isLong,
      'indicators': indicators,
    };
  }

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final text = value?.toString().trim().toLowerCase();

    return text == 'true' ||
        text == '1' ||
        text == 'yes';
  }
}