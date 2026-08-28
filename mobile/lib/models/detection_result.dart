class DetectionResult {
  final String prediction;
  final int label;
  final double confidence;
  final double scamProbability;

  final bool confidenceIsCalibrated;
  final String confidenceSource;

  final String riskLevel;
  final double decisionThreshold;

  final String modelVersion;
  final List<String> indicators;

  final String source;
  final int messageLength;
  final int scanId;
  final String timestamp;

  const DetectionResult({
    required this.prediction,
    required this.label,
    required this.confidence,
    required this.scamProbability,
    required this.confidenceIsCalibrated,
    required this.confidenceSource,
    required this.riskLevel,
    required this.decisionThreshold,
    required this.modelVersion,
    required this.indicators,
    required this.source,
    required this.messageLength,
    required this.scanId,
    required this.timestamp,
  });

  /// Whether the model classified the message as a scam/phishing threat.
  bool get isScam {
    return prediction.trim().toUpperCase() != 'SAFE';
  }

  /// Human-readable calibration status.
  String get calibration {
    return confidenceIsCalibrated
        ? 'Calibrated'
        : 'Not calibrated';
  }

  /// Backward-compatible model name.
  String get model {
    return modelVersion;
  }

  /// Backward-compatible explanation field.
  List<String> get reasons {
    return indicators;
  }

  /// Whether the result is considered safe.
  bool get isSafe {
    return !isScam;
  }

  /// Confidence represented as a percentage.
  double get confidencePercent {
    return confidence * 100;
  }

  /// Scam probability represented as a percentage.
  double get scamProbabilityPercent {
    return scamProbability * 100;
  }

  factory DetectionResult.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawIndicators =
        json['indicators'] ??
        json['reasons'] ??
        const <dynamic>[];

    final indicators = rawIndicators is List
        ? rawIndicators
            .map((item) => item.toString())
            .where((item) => item.trim().isNotEmpty)
            .toList()
        : <String>[];

    return DetectionResult(
      prediction:
          json['prediction']?.toString() ?? 'UNKNOWN',

      label: _toInt(json['label']),

      confidence:
          _toDouble(json['confidence']),

      scamProbability:
          _toDouble(
            json['scam_probability'] ??
                json['scamProbability'],
          ),

      confidenceIsCalibrated:
          _toBool(
            json['confidence_is_calibrated'] ??
                json['confidenceIsCalibrated'],
          ),

      confidenceSource:
          json['confidence_source']?.toString() ??
          json['confidenceSource']?.toString() ??
          json['calibration']?.toString() ??
          'Unknown',

      riskLevel:
          json['risk_level']?.toString() ??
          json['riskLevel']?.toString() ??
          'UNKNOWN',

      decisionThreshold:
          _toDouble(
            json['decision_threshold'] ??
                json['decisionThreshold'],
          ),

      modelVersion:
          json['model_version']?.toString() ??
          json['modelVersion']?.toString() ??
          json['model']?.toString() ??
          'Unknown',

      indicators: indicators,

      source:
          json['source']?.toString() ?? 'SMS',

      messageLength:
          _toInt(json['message_length']),

      scanId:
          _toInt(
            json['scan_id'] ??
                json['scanId'],
          ),

      timestamp:
          json['timestamp']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prediction': prediction,
      'label': label,
      'confidence': confidence,
      'scam_probability': scamProbability,
      'confidence_is_calibrated':
          confidenceIsCalibrated,
      'confidence_source': confidenceSource,
      'risk_level': riskLevel,
      'decision_threshold': decisionThreshold,
      'model_version': modelVersion,
      'indicators': indicators,
      'source': source,
      'message_length': messageLength,
      'scan_id': scanId,
      'timestamp': timestamp,
    };
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }

  static int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final text =
        value?.toString().trim().toLowerCase();

    return text == 'true' ||
        text == '1' ||
        text == 'yes';
  }
}