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
  final TextEditingController _urlController = TextEditingController();

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
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'URL Security Analyzer',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 7),
              Text(
                'Inspect a suspicious link for common security indicators before opening it.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.58),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              _buildInputCard(),
              if (_result != null) ...[
                const SizedBox(height: 18),
                _buildResult(_result!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard() {
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
          const Text(
            'Enter URL',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _urlController,
            enabled: !_loading,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _analyze(),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.link_rounded),
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
                  icon: const Icon(Icons.clear_rounded),
                  label: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 10),
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
                      : const Icon(Icons.search_rounded),
                  label: Text(
                    _loading ? 'Analyzing...' : 'Analyze URL',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResult(UrlAnalysis result) {
    final hasWarnings = result.indicators.any(
      (indicator) =>
          !indicator.toLowerCase().startsWith('host:'),
    );

    final Color statusColor = hasWarnings
        ? const Color(0xFFFFC857)
        : const Color(0xFF20D3C2);

    final IconData statusIcon = hasWarnings
        ? Icons.warning_amber_rounded
        : Icons.verified_rounded;

    final String statusTitle = hasWarnings
        ? 'Security indicators found'
        : 'No obvious indicators found';

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
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withValues(alpha: 0.10),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.30),
                  ),
                ),
                child: Icon(
                  statusIcon,
                  size: 42,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                statusTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'URL inspection is an indicator-based security check, not proof that a website is safe or malicious.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.58),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'URL Details',
          children: [
            _infoRow(
              'URL',
              result.url,
            ),
            _infoRow(
              'Scheme',
              result.scheme.isEmpty ? 'Unknown' : result.scheme,
            ),
            _infoRow(
              'Host',
              result.host.isEmpty ? 'Unknown' : result.host,
            ),
            _infoRow(
              'Valid',
              result.valid ? 'Yes' : 'No',
            ),
            _infoRow(
              'HTTPS',
              result.isHttps ? 'Yes' : 'No',
            ),
            _infoRow(
              'Long URL',
              result.isLong ? 'Yes' : 'No',
            ),
            _infoRow(
              'Shortener',
              result.isShortener ? 'Detected' : 'Not detected',
            ),
            _infoRow(
              'Embedded username',
              result.hasUsername ? 'Detected' : 'Not detected',
            ),
            _infoRow(
              'Non-default port',
              result.hasNonDefaultPort ? 'Detected' : 'Not detected',
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
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          indicator.toLowerCase().startsWith('host:')
                              ? Icons.dns_outlined
                              : Icons.warning_amber_rounded,
                          size: 18,
                          color: indicator.toLowerCase().startsWith('host:')
                              ? const Color(0xFF20D3C2)
                              : statusColor,
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
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1725),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF17394D),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.verified_user_outlined,
                color: Color(0xFF20D3C2),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Do not rely on HTTPS alone. Verify the domain, sender and context before entering passwords, payment details or other sensitive information.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.58),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
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
            width: 125,
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