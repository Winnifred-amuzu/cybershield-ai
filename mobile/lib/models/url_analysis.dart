class UrlAnalysis {
  final String url;
  final bool valid;
  final bool https;
  final bool longUrl;
  final bool shortener;
  final String host;
  final List<String> indicators;
  final String prediction;
  final double confidence;

  const UrlAnalysis({
    required this.url,
    required this.valid,
    required this.https,
    required this.longUrl,
    required this.shortener,
    required this.host,
    required this.indicators,
    required this.prediction,
    required this.confidence,
  });

  bool get isScam => prediction.toUpperCase() != 'SAFE';

  factory UrlAnalysis.fromJson(Map<String, dynamic> json) {
    final rawIndicators = json['indicators'] ?? const [];

    return UrlAnalysis(
      url: json['url']?.toString() ?? '',
      valid: json['valid'] as bool? ?? false,
      https: json['https'] as bool? ?? false,
      longUrl: json['long_url'] as bool? ??
          json['longUrl'] as bool? ??
          false,
      shortener: json['shortener'] as bool? ?? false,
      host: json['host']?.toString() ?? '',
      indicators: rawIndicators is List
          ? rawIndicators.map((item) => item.toString()).toList()
          : <String>[],
      prediction: json['prediction']?.toString() ?? 'UNKNOWN',
      confidence: _toDouble(json['confidence']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'valid': valid,
      'https': https,
      'long_url': longUrl,
      'shortener': shortener,
      'host': host,
      'indicators': indicators,
      'prediction': prediction,
      'confidence': confidence,
    };
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }

    return 0.0;
  }
}