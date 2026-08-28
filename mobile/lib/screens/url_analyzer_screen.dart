import 'package:flutter/material.dart';

import '../models/url_analysis.dart';
import '../services/api_service.dart';
import '../services/text_utils.dart';

class UrlAnalyzerScreen extends StatefulWidget {
  const UrlAnalyzerScreen({super.key});

  @override
  State<UrlAnalyzerScreen> createState() => _UrlAnalyzerScreenState();
}

class _UrlAnalyzerScreenState extends State<UrlAnalyzerScreen> {
  final TextEditingController _urlController =
      TextEditingController();

  UrlAnalysis? _result;
  bool _loading = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final url = _urlController.text.trim();

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a URL.'),
        ),
      );
      return;
    }

    if (_loading) {
      return;
    }

    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      final result = await ApiService.instance.analyzeUrl(url);

      if (!mounted) {
        return;
      }

      setState(() {
        _result = result;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(TextUtils.cleanError(error)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _clear() {
    _urlController.clear();

    setState(() {
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('URL Analyzer'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Analyze a URL',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check a suspicious link for common security indicators.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.60),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _urlController,
                enabled: !_loading,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _analyze(),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.link),
                  hintText: 'https://example.com',
                  labelText: 'URL',
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _loading ? null : _clear,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _loading ? null : _analyze,
                      icon: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.search),
                      label: Text(
                        _loading ? 'Analyzing...' : 'Analyze URL',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_result != null) _buildResult(_result!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult(UrlAnalysis result) {
    final isScam = result.isScam;

    final Color statusColor =
        isScam ? Colors.redAccent : Colors.tealAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1D29),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            children: [
              Icon(
                isScam
                    ? Icons.warning_amber_rounded
                    : Icons.verified_rounded,
                size: 48,
                color: statusColor,
              ),
              const SizedBox(height: 12),
              Text(
                result.prediction,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Confidence: ${TextUtils.formatPercent(result.confidence)}',
                style: const TextStyle(
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'URL Details',
          children: [
            _infoRow('URL', result.url),
            _infoRow('Host', result.host.isEmpty ? 'Unknown' : result.host),
            _infoRow(
              'Valid',
              result.valid ? 'Yes' : 'No',
            ),
            _infoRow(
              'HTTPS',
              result.https ? 'Yes' : 'No',
            ),
            _infoRow(
              'Long URL',
              result.longUrl ? 'Yes' : 'No',
            ),
            _infoRow(
              'Shortener',
              result.shortener ? 'Detected' : 'Not detected',
            ),
          ],
        ),
        if (result.indicators.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Security Indicators',
            children: result.indicators
                .map(
                  (indicator) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isScam
                              ? Icons.warning_amber_rounded
                              : Icons.info_outline,
                          size: 18,
                          color: statusColor,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            indicator,
                            style: const TextStyle(
                              color: Colors.white70,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
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
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}