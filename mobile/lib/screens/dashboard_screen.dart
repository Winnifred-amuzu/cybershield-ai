import 'package:flutter/material.dart';

import '../models/dashboard_data.dart';
import '../services/api_service.dart';
import '../widgets/cyber_card.dart';
import '../widgets/metric_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final api = const ApiService();
  late Future<DashboardData> future;

  @override
  void initState() {
    super.initState();
    future = api.getDashboard();
  }

  Future<void> refresh() async {
    setState(() {
      future = api.getDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardData>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return _ErrorState(
            message: snapshot.error.toString(),
            onRetry: refresh,
          );
        }

        final data = snapshot.data!;

        final total = data.totalScans == 0 ? 1 : data.totalScans;
        final scamRatio = data.scamScans / total;

        return RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
            children: [
              const Text(
                'Security Dashboard',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'A quick view of your recent detection activity.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.45,
                children: [
                  MetricCard(
                    label: 'Total scans',
                    value: '${data.totalScans}',
                    icon: Icons.radar_rounded,
                    color: const Color(0xFF20D3C2),
                  ),
                  MetricCard(
                    label: 'Threats found',
                    value: '${data.threatsFound}',
                    icon: Icons.warning_amber_rounded,
                    color: const Color(0xFFFF6B6B),
                  ),
                  MetricCard(
                    label: 'Safe scans',
                    value: '${data.safeScans}',
                    icon: Icons.verified_rounded,
                    color: const Color(0xFF5EE6A8),
                  ),
                  MetricCard(
                    label: 'Scam scans',
                    value: '${data.scamScans}',
                    icon: Icons.security_rounded,
                    color: const Color(0xFFFFC857),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CyberCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detection distribution',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        minHeight: 12,
                        value: scamRatio,
                        backgroundColor: const Color(0xFF163046),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFFFF5F6D),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${data.scamScans} threats',
                          style: const TextStyle(
                            color: Color(0xFFFF8A8A),
                          ),
                        ),
                        Text(
                          '${data.safeScans} safe',
                          style: const TextStyle(
                            color: Color(0xFF5EE6A8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              CyberCard(
                child: Row(
                  children: [
                    const Icon(
                      Icons.insights_outlined,
                      color: Color(0xFF20D3C2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The dashboard reflects scans stored by the shared backend history database.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.58),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: Color(0xFFFF8A8A),
            ),
            const SizedBox(height: 14),
            const Text(
              'Backend unavailable',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the FastAPI backend and check the mobile API URL.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}