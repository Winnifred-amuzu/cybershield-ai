import 'package:flutter/material.dart';
import '../services/api_service.dart';
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
  const HomeScreen({super.key, this.userName});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  final pages = const [DetectionScreen(), DashboardScreen(), HistoryScreen(), ModelPerformanceScreen()];

  Future<void> logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 18,
        title: Row(children: [
          Container(width: 34,height:34,decoration:BoxDecoration(color:const Color(0xFF20D3C2).withOpacity(.12),borderRadius:BorderRadius.circular(11)),child:const Icon(Icons.shield_outlined,color:Color(0xFF20D3C2),size:21)),
          const SizedBox(width:10), const Text('Cyber-Shield AI',style:TextStyle(fontWeight:FontWeight.w800)),
        ]),
        actions: [
          IconButton(tooltip:'URL Analyzer',onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const UrlAnalyzerScreen())),icon:const Icon(Icons.link_rounded)),
          PopupMenuButton<String>(onSelected:(value){if(value=='status') Navigator.push(context, MaterialPageRoute(builder: (_) => const SystemStatusScreen()));
          if(value=='logout')logout();},itemBuilder:(_)=>[
            PopupMenuItem(enabled:false,child:Text(widget.userName == null ? 'Account' : widget.userName!)),
            const PopupMenuItem(value:'status',child:Text('System status')),
            const PopupMenuItem(value:'logout',child:Text('Sign out')),
          ]),
        ],
      ),
      body: IndexedStack(index:index,children:pages),
      bottomNavigationBar: NavigationBar(selectedIndex:index,onDestinationSelected:(value)=>setState(()=>index=value),destinations:const [
        NavigationDestination(icon:Icon(Icons.radar_rounded),selectedIcon:Icon(Icons.radar_rounded),label:'Detect'),
        NavigationDestination(icon:Icon(Icons.dashboard_outlined),selectedIcon:Icon(Icons.dashboard_rounded),label:'Dashboard'),
        NavigationDestination(icon:Icon(Icons.history_rounded),label:'History'),
        NavigationDestination(icon:Icon(Icons.analytics_outlined),label:'Models'),
      ]),
    );
  }
}
