class ModelPerformance {
  final String model;
  final double accuracy;
  final double precision;
  final double recall;
  final double f1;

  const ModelPerformance({
    required this.model,
    required this.accuracy,
    required this.precision,
    required this.recall,
    required this.f1,
  });

  factory ModelPerformance.fromJson(Map<String, dynamic> json) {
    return ModelPerformance(
      model: json['model'] as String? ?? 'Unknown',
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
      precision: (json['precision'] as num?)?.toDouble() ?? 0,
      recall: (json['recall'] as num?)?.toDouble() ?? 0,
      f1: (json['f1'] as num?)?.toDouble() ?? 0,
    );
  }
}
