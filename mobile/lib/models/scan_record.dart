class ScanRecord {
  final int id;
  final String message;
  final String source;
  final String prediction;
  final double confidence;
  final String timestamp;

  const ScanRecord({
    required this.id,
    required this.message,
    required this.source,
    required this.prediction,
    required this.confidence,
    required this.timestamp,
  });

  bool get isScam => prediction != 'SAFE';

  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    return ScanRecord(
      id: (json['id'] as num?)?.toInt() ?? 0,
      message: json['message'] as String? ?? '',
      source: json['source'] as String? ?? 'SMS',
      prediction: json['prediction'] as String? ?? 'UNKNOWN',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      timestamp: json['timestamp'] as String? ?? '',
    );
  }
}
