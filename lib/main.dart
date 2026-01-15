import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/objectbox_service.dart';
import 'services/export_service.dart';
import 'providers/titan_provider.dart';
import 'screens/home_page.dart';
import 'screens/tree_page.dart';
import 'screens/history_page.dart';
import 'screens/progress_page.dart';
import 'screens/expected_progress_page.dart';
import 'screens/measurements_page.dart';
import 'screens/library_page.dart';
import 'screens/body_visualizer_page.dart';
import 'screens/relic_vault_page.dart';
import 'screens/protocol_editor_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = await ObjectBoxService.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => TitanProvider(service: service),
      child: MyGymApp(),
    ),
  );
}

class MyGymApp extends StatelessWidget {
  const MyGymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Titan Log Pro',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.orangeAccent,
        scaffoldBackgroundColor: const Color(0xFF050505),
        colorScheme: const ColorScheme.dark(
          primary: Colors.orangeAccent,
          secondary: Colors.orangeAccent,
        ),
      ),
      home: const MainNavigationWrapper(),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  _MainNavigationWrapperState createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  double _rawVal(dynamic v) => (v is num) ? v.toDouble() : 0.0;

  void _generateTitanID(TitanProvider provider) {
    final data = provider.bodyData;
    double w = _rawVal(data['weight']);
    double h = _rawVal(data['height']);
    double bf = _rawVal(data['bf']);
    double wrist = _rawVal(data['wrist'] ?? 17.5);

    double leanMass = w * (1 - (bf / 100.0));
    double ffmi = (h > 0) ? (leanMass / ((h / 100) * (h / 100))) + (6.3 * (1.8 - (h / 100))) : 0.0;
    double rRatio = (wrist > 0) ? h / wrist : 10.0;

    String combatClass = ffmi < 19.0 ? "THE GENESIS" : "THE TITAN";
    Color classColor = ffmi < 19.0 ? Colors.white54 : Colors.orangeAccent;

    if (rRatio > 10.4 && ffmi > 21.0) {
      combatClass = "THE PEAK";
      classColor = Colors.cyanAccent;
    }
    if (rRatio < 9.6 && ffmi > 22.0) {
      combatClass = "THE HYBRID";
      classColor = Colors.redAccent;
    }

    ExportService.generateAndShareId(
      context: context,
      bodyData: data,
      combatClass: combatClass,
      classColor: classColor,
      ffmi: ffmi,
      chassis: rRatio > 10.4 ? "LIGHT" : "HEAVY",
      rarity: (ffmi * 4).toInt().toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TitanProvider>();

    final List<Widget> corePages = [
      const HomePage(),
      const TreePage(),
      const HistoryPage(),
      _buildHubMenu(provider),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: corePages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF111111),
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.white38,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "HOME"),
          BottomNavigationBarItem(icon: Icon(Icons.architecture_rounded), label: "PLAN"),
          BottomNavigationBarItem(icon: Icon(Icons.history_edu_rounded), label: "LOG"),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "HUB"),
        ],
      ),
    );
  }

  Widget _buildHubMenu(TitanProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          const Text("TITAN COMMAND",
              style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -2)),
          const SizedBox(height: 30),
          _hubActionCard("GENERATE TITAN ID", Icons.fingerprint, Colors.cyanAccent, () => _generateTitanID(provider)),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _hubTile("ANALYTICS", Icons.analytics_outlined, Colors.orangeAccent, () => _open(const ProgressPage())),
                _hubTile("ROADMAPS", Icons.track_changes_rounded, Colors.blueAccent, () => _open(const ExpectedProgressPage())),
                _hubTile("BODY STATS", Icons.person_search_rounded, Colors.greenAccent, () => _open(const MeasurementsPage())),
                _hubTile("LIBRARY", Icons.book_rounded, Colors.purpleAccent, () => _open(const LibraryPage())),
                _hubTile("EVOLUTION", Icons.accessibility_new_rounded, Colors.redAccent, () => _open(const BodyVisualizerPage())),
                _hubTile("RELIC VAULT", Icons.military_tech, Colors.amberAccent, () => _open(const RelicVaultPage())),
                _hubTile("PROTOCOL FORGE", Icons.code_rounded, Colors.cyanAccent, () => _open(const ProtocolEditorPage())),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hubActionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: color.withOpacity(0.4))
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 34),
          const SizedBox(width: 20),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
        ]),
      ),
    );
  }

  Widget _hubTile(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: color.withOpacity(0.2))
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
      ),
    );
  }

  void _open(Widget page) => Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}