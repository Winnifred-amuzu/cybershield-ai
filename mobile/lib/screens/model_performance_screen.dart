import 'package:flutter/material.dart';

import '../models/model_performance.dart';
import '../services/api_service.dart';
import '../services/text_utils.dart';
import '../widgets/cyber_card.dart';

class ModelPerformanceScreen extends StatefulWidget {
  const ModelPerformanceScreen({super.key});
  @override
  State<ModelPerformanceScreen> createState() => _ModelPerformanceScreenState();
}

class _ModelPerformanceScreenState extends State<ModelPerformanceScreen> {
  final api = const ApiService();
  late Future<List<ModelPerformance>> future;
  @override
  void initState() { super.initState(); future = api.getModelPerformance(); }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ModelPerformance>>(future: future, builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError) return Center(child: Text('Unable to load model performance.\n${snapshot.error}', textAlign: TextAlign.center));
      final records = snapshot.data!;
      final best = records.isEmpty ? null : records.reduce((a, b) => a.f1 >= b.f1 ? a : b);
      return ListView(padding: const EdgeInsets.fromLTRB(18, 10, 18, 30), children: [
        const Text('Model Performance', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text('Performance reported by the existing project artefacts.', style: TextStyle(color: Colors.white.withValues(alpha: .5))),
        const SizedBox(height: 18),
        if (best != null) CyberCard(child: Row(children: [const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFC857), size: 30), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Selected model', style: TextStyle(color: Colors.white54, fontSize: 11)), Text(best.model, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), Text('F1 ${TextUtils.formatPercent(best.f1)}', style: const TextStyle(color: Color(0xFF20D3C2), fontWeight: FontWeight.w700))]))])),
        const SizedBox(height: 14),
        ...records.map((record) => Padding(padding: const EdgeInsets.only(bottom: 11), child: CyberCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(record.model, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))), Text('F1 ${TextUtils.formatPercent(record.f1)}', style: const TextStyle(color: Color(0xFF20D3C2), fontWeight: FontWeight.w800))]), const SizedBox(height: 14), _bar('Accuracy', record.accuracy), _bar('Precision', record.precision), _bar('Recall', record.recall), _bar('F1', record.f1)])))),
        const SizedBox(height: 8),
        Text('These are held-out evaluation metrics from the existing project. They do not guarantee performance on future or unseen scam campaigns.', style: TextStyle(color: Colors.white.withValues(alpha: .38), fontSize: 11, height: 1.45)),
      ]);
    });
  }

  Widget _bar(String label, double value) => Padding(padding: const EdgeInsets.only(bottom: 9), child: Row(children: [SizedBox(width: 62, child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54))), Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: value, minHeight: 7, backgroundColor: const Color(0xFF18334A), valueColor: const AlwaysStoppedAnimation(Color(0xFF20D3C2))))), const SizedBox(width: 8), SizedBox(width: 40, child: Text(TextUtils.formatPercent(value), textAlign: TextAlign.right, style: const TextStyle(fontSize: 10)))]));
}
