import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ShareService {
  StreamSubscription<List<SharedMediaFile>>? _subscription;

  void listen({
    required void Function(String text) onText,
    required void Function(String path) onImagePath,
  }) {
    _subscription = ReceiveSharingIntent.instance.getMediaStream().listen((items) {
      _handleItems(items, onText: onText, onImagePath: onImagePath);
    });

    ReceiveSharingIntent.instance.getInitialMedia().then((items) {
      _handleItems(items, onText: onText, onImagePath: onImagePath);
      if (items.isNotEmpty) ReceiveSharingIntent.instance.reset();
    });
  }

  void _handleItems(
    List<SharedMediaFile> items, {
    required void Function(String text) onText,
    required void Function(String path) onImagePath,
  }) {
    for (final item in items) {
      final text = item.message?.trim();
      if (text != null && text.isNotEmpty) {
        onText(text);
        continue;
      }

      final path = item.path.trim();
      final type = item.type.toString().toLowerCase();
      if (path.isNotEmpty && (type.contains('image') || _looksLikeImage(path))) {
        onImagePath(path);
      }
    }
  }

  bool _looksLikeImage(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp');
  }

  Future<void> dispose() async => _subscription?.cancel();
}
