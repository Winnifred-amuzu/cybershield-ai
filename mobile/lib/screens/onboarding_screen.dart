import 'package:flutter/material.dart';

import '../services/preferences_service.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  final pages = const [
    _OnboardData(Icons.shield_outlined, 'Detect suspicious messages', 'Analyse SMS, email and WhatsApp text with the existing Cyber-Shield AI model.'),
    _OnboardData(Icons.warning_amber_rounded, 'Understand the warning', 'See risk level and transparent indicators such as urgency, financial language and suspicious URLs.'),
    _OnboardData(Icons.lock_outline, 'Verify before you act', 'Cyber-Shield AI is a warning assistant, not proof. Independently verify sensitive requests through trusted channels.'),
  ];

  Future<void> _finish() async {
    await PreferencesService.completeOnboarding();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            SizedBox(
              height: 390,
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (value) => setState(() => _page = value),
                itemBuilder: (_, index) => _OnboardPage(data: pages[index]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 7,
                width: index == _page ? 24 : 7,
                decoration: BoxDecoration(color: index == _page ? const Color(0xFF20D3C2) : const Color(0xFF28445C), borderRadius: BorderRadius.circular(20)),
              )),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () {
                    if (_page == pages.length - 1) {
                      _finish();
                    } else {
                      _controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
                    }
                  },
                  child: Text(_page == pages.length - 1 ? 'Get Started' : 'Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardData {
  final IconData icon;
  final String title;
  final String body;
  const _OnboardData(this.icon, this.title, this.body);
}

class _OnboardPage extends StatelessWidget {
  final _OnboardData data;
  const _OnboardPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF20D3C2).withOpacity(.1), border: Border.all(color: const Color(0xFF20D3C2).withOpacity(.3))),
            child: Icon(data.icon, size: 58, color: const Color(0xFF20D3C2)),
          ),
          const SizedBox(height: 38),
          Text(data.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Text(data.body, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, height: 1.6, color: Colors.white.withOpacity(.65))),
        ],
      ),
    );
  }
}
