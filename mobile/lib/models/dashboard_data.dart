class DashboardData {
  final int totalScans;
  final int threatsFound;
  final int safeScans;
  final int scamScans;
  final Map<String, int> distribution;

  const DashboardData({
    required this.totalScans,
    required this.threatsFound,
    required this.safeScans,
    required this.scamScans,
    required this.distribution,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final raw = Map<String, dynamic>.from(json['distribution'] ?? {});
    return DashboardData(
      totalScans: (json['total_scans'] as num?)?.toInt() ?? 0,
      threatsFound: (json['threats_found'] as num?)?.toInt() ?? 0,
      safeScans: (json['safe_scans'] as num?)?.toInt() ?? 0,
      scamScans: (json['scam_scans'] as num?)?.toInt() ?? 0,
      distribution: raw.map((key, value) => MapEntry(key, (value as num).toInt())),
    );
  }
}
