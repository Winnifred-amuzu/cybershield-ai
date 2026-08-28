import 'package:flutter/material.dart';

import '../models/detection_result.dart';
import '../services/text_utils.dart';
import '../widgets/cyber_card.dart';
import '../widgets/status_pill.dart';

class ResultScreen extends StatelessWidget {
  final DetectionResult result;
  final String originalMessage;

  const ResultScreen({super.key, required this.result, required this.originalMessage});

  Color get statusColor => result.isScam ? const Color(0xFFFF5F6D) : const Color(0xFF20D3C2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analysis Result')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
        child: Column(children: [
          const SizedBox(height: 12),
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withOpacity(.1),
              border: Border.all(color: statusColor.withOpacity(.35), width: 2),
            ),
            child: Icon(result.isScam ? Icons.warning_amber_rounded : Icons.verified_rounded, color: statusColor, size: 48),
          ),
          const SizedBox(height: 18),
          Text(result.prediction, textAlign: TextAlign.center, style: TextStyle(color: statusColor, fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          StatusPill(label: result.riskLevel, color: statusColor, icon: Icons.shield_outlined),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _Metric(label: 'Confidence', value: TextUtils.formatPercent(result.confidence))),
            const SizedBox(width: 10),
            Expanded(child: _Metric(label: 'Scam probability', value: TextUtils.formatPercent(result.scamProbability))),
            const SizedBox(width: 10),
            Expanded(child: _Metric(label: 'Scan', value: '#${result.scanId}')),
          ]),
          const SizedBox(height: 16),
          CyberCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Model evidence', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              _EvidenceRow(label: 'Calibration', value: result.confidenceIsCalibrated ? 'Calibrated' : 'Not calibrated'),
              _EvidenceRow(label: 'Source', value: result.confidenceSource),
              _EvidenceRow(label: 'Decision threshold', value: TextUtils.formatPercent(result.decisionThreshold)),
              _EvidenceRow(label: 'Model', value: result.modelVersion),
            ]),
          ),
          if (!result.confidenceIsCalibrated) ...[
            const SizedBox(height: 14),
            CyberCard(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.info_outline, color: Color(0xFFFFC857)),
              const SizedBox(width: 10),
              Expanded(child: Text(
                'The calibrated model is not active yet. This result is using the legacy LinearSVC fallback. Run the Sprint 5 calibration training script before treating confidence as a probability.',
                style: TextStyle(color: Colors.white.withOpacity(.65), fontSize: 12, height: 1.45),
              )),
            ])),
          ],
          const SizedBox(height: 14),
          CyberCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Why this result?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            if (result.indicators.isEmpty) Text('No suspicious patterns were detected by the explanation layer.', style: TextStyle(color: Colors.white.withOpacity(.58))),
            ...result.indicators.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(result.isScam ? Icons.warning_amber_rounded : Icons.info_outline, size: 18, color: statusColor),
                const SizedBox(width: 9),
                Expanded(child: Text(item, style: const TextStyle(height: 1.35))),
              ]),
            )),
          ])),
          const SizedBox(height: 14),
          CyberCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Message preview', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(TextUtils.preview(originalMessage, max: 260), style: TextStyle(color: Colors.white.withOpacity(.58), height: 1.45)),
          ])),
          const SizedBox(height: 22),
          SizedBox(width: double.infinity, height: 54, child: FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.radar_rounded),
            label: const Text('Analyze Another Message'),
          )),
        ]),
      ),
    );
  }
}

class _EvidenceRow extends StatelessWidget {
  final String label;
  final String value;
  const _EvidenceRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(children: [
      Expanded(child: Text(label, style: TextStyle(color: Colors.white.withOpacity(.5), fontSize: 12))),
      Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
    ]),
  );
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => CyberCard(
    padding: const EdgeInsets.all(13),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(color: Colors.white.withOpacity(.45), fontSize: 10)),
    ]),
  );
}
