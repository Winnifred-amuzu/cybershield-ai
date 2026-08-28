import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'detection_screen.dart';
import 'history_screen.dart';
import 'model_performance_screen.dart';
import 'url_analyzer_screen.dart';
import 'login_screen.dart';
import 'system_status_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? userName;

  const HomeScreen({
    super.key,
    this.userName,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  final pages = const [
    DetectionScreen(),
    DashboardScreen(),
    HistoryScreen(),
    ModelPerformanceScreen(),
  ];

  Future<void> logout() async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (_) => false,
    );
  }

  void openUrlAnalyzer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UrlAnalyzerScreen(),
      ),
    );
  }

  void openSystemStatus() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SystemStatusScreen(),
      ),
    );
  }

  void handleMenuSelection(String value) {
    switch (value) {
      case 'status':
        openSystemStatus();
        break;

      case 'logout':
        logout();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF20D3C2);
    const backgroundColor = Color(0xFF07111F);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        titleSpacing: 18,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: accentColor,
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Cyber-Shield AI',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'URL Analyzer',
            onPressed: openUrlAnalyzer,
            icon: const Icon(Icons.link_rounded),
          ),
          PopupMenuButton<String>(
            onSelected: handleMenuSelection,
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Text(
                  widget.userName == null || widget.userName!.trim().isEmpty
                      ? 'Account'
                      : widget.userName!,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'status',
                child: Text('System status'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Sign out'),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          setState(() {
            index = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.radar_rounded),
            selectedIcon: Icon(Icons.radar_rounded),
            label: 'Detect',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded),
            label: 'Models',
          ),
        ],
      ),
    );
  }
}