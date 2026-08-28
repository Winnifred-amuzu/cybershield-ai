import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/text_utils.dart';

class SystemStatusScreen extends StatefulWidget {
  const SystemStatusScreen({super.key});

  @override
  State<SystemStatusScreen> createState() =>
      _SystemStatusScreenState();
}

class _SystemStatusScreenState
    extends State<SystemStatusScreen> {
  bool _loading = true;

  Map<String, dynamic>? _health;
  Map<String, dynamic>? _model;

  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        ApiService.instance.getSystemHealth(),
        ApiService.instance.getModelStatus(),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _health = results[0];
        _model = results[1];
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = TextUtils.cleanError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _statusValue(Map<String, dynamic>? data) {
    if (data == null) {
      return 'Unavailable';
    }

    return data['status']?.toString() ??
        data['health']?.toString() ??
        'Available';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Status'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadStatus,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: _loadStatus,
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    if (_error != null)
                      _buildError(_error!),
                    _buildStatusCard(
                      title: 'API Server',
                      value: _statusValue(_health),
                      icon: Icons.cloud_done_outlined,
                    ),
                    const SizedBox(height: 14),
                    _buildStatusCard(
                      title: 'Machine Learning Model',
                      value: _statusValue(_model),
                      icon: Icons.psychology_outlined,
                    ),
                    if (_health != null) ...[
                      const SizedBox(height: 20),
                      _buildDataCard(
                        'API Information',
                        _health!,
                      ),
                    ],
                    if (_model != null) ...[
                      const SizedBox(height: 20),
                      _buildDataCard(
                        'Model Information',
                        _model!,
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.redAccent.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final bool healthy = value.toLowerCase().contains('ok') ||
        value.toLowerCase().contains('healthy') ||
        value.toLowerCase().contains('available');

    final color = healthy ? Colors.tealAccent : Colors.orangeAccent;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1D29),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF17394D),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(
    String title,
    Map<String, dynamic> data,
  ) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1D29),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF17394D),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...data.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}