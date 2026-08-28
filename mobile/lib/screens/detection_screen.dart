import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../services/api_service.dart';
import '../services/text_utils.dart';
import '../services/share_service.dart';
import '../widgets/cyber_card.dart';
import 'result_screen.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  final _controller = TextEditingController();
  final _api = const ApiService();
  final _picker = ImagePicker();
  String _source = 'SMS';
  bool _loading = false;
  String? _error;
  final _shareService = ShareService();

  @override
  void initState() {
    super.initState();
    _shareService.listen(
      onText: (text) {
        if (!mounted) return;
        setState(() { _controller.text = text; _error = null; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shared message imported. Review it before analysing.')));
      },
      onImagePath: _extractTextFromSharedImage,
    );
  }

  @override
  void dispose() {
    _shareService.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final message = _controller.text.trim();
    if (message.isEmpty) {
      setState(() => _error = 'Enter or extract a message before analysing it.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final result = await _api.detect(message: message, source: _source);
      if (!mounted) return;
      await Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(result: result, originalMessage: message)));
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _extractTextFromSharedImage(String path) async {
    try {
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final input = InputImage.fromFilePath(path);
      final recognized = await recognizer.processImage(input);
      await recognizer.close();
      if (recognized.text.trim().isEmpty) {
        if (mounted) setState(() => _error = 'No readable text was found in the shared image.');
        return;
      }
      if (!mounted) return;
      setState(() { _controller.text = recognized.text.trim(); _error = null; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shared screenshot text extracted. Review it before analysing.')));
    } catch (e) {
      if (mounted) setState(() => _error = 'Shared-image OCR failed: $e');
    }
  }

  Future<void> _scanScreenshot() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
      if (image == null) return;
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final input = InputImage.fromFilePath(image.path);
      final recognized = await recognizer.processImage(input);
      await recognizer.close();
      if (recognized.text.trim().isEmpty) {
        if (mounted) setState(() => _error = 'No readable text was found in that image.');
        return;
      }
      setState(() { _controller.text = recognized.text.trim(); _error = null; });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Text extracted from screenshot. Review it before analysing.')));
    } catch (e) {
      if (mounted) setState(() => _error = 'Screenshot OCR failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 10),
        Text('AI Scam Detector', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 7),
        Text('Check a suspicious message before you click, reply or pay.', style: TextStyle(color: Colors.white.withOpacity(.58), height: 1.4)),
        const SizedBox(height: 22),
        CyberCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Message source', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(value: _source, decoration: const InputDecoration(prefixIcon: Icon(Icons.forum_outlined)), items: const [
            DropdownMenuItem(value: 'SMS', child: Text('SMS')),
            DropdownMenuItem(value: 'WhatsApp', child: Text('WhatsApp')),
            DropdownMenuItem(value: 'Email', child: Text('Email')),
          ], onChanged: (value) => setState(() => _source = value ?? 'SMS')),
          const SizedBox(height: 18),
          const Text('Message', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          TextField(controller: _controller, minLines: 8, maxLines: 12, maxLength: 5000, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(hintText: 'Paste or type the suspicious message here...', alignLabelWithHint: true)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: _loading ? null : _scanScreenshot, icon: const Icon(Icons.image_search_rounded), label: const Text('Scan Screenshot'))),
            const SizedBox(width: 10),
            Expanded(child: FilledButton.icon(onPressed: _loading ? null : _analyze, icon: _loading ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.radar_rounded), label: Text(_loading ? 'Analysing…' : 'Analyze'))),
          ]),
        ])),
        if (_error != null) ...[
          const SizedBox(height: 14),
          CyberCard(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.error_outline, color: Color(0xFFFF8A8A)), const SizedBox(width: 10), Expanded(child: Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), height: 1.4)))])),
        ],
        const SizedBox(height: 18),
        CyberCard(child: Row(children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFF20D3C2).withOpacity(.1), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.verified_user_outlined, color: Color(0xFF20D3C2))),
          const SizedBox(width: 12),
          Expanded(child: Text('Use every result as a warning signal. Verify sensitive requests through a trusted channel.', style: TextStyle(color: Colors.white.withOpacity(.62), fontSize: 12.5, height: 1.4))),
        ])),
        const SizedBox(height: 10),
        Text('Detected URLs: ${TextUtils.extractUrls(_controller.text).length}', style: TextStyle(color: Colors.white.withOpacity(.35), fontSize: 11)),
      ]),
    );
  }
}
