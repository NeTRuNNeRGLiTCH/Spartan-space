import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'models/workout_node.dart';
import 'models/workout_log.dart';
import 'models/goal_node.dart';
import 'models/relic.dart';
import 'services/storage_service.dart';
import 'services/export_service.dart';
import 'screens/home_page.dart';
import 'screens/tree_page.dart';
import 'screens/history_page.dart';
import 'screens/progress_page.dart';
import 'screens/expected_progress_page.dart';
import 'screens/measurements_page.dart';
import 'screens/library_page.dart';
import 'screens/body_visualizer_page.dart';
import 'screens/relic_vault_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('gym_data');
  runApp(const MyGymApp());
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
  List<WorkoutNode> myPlans = [];
  List<WorkoutLog> myLogs = [];
  List<GoalNode> myGoals = [];
  Map<String, dynamic> myBodyData = {};
  Map<String, List<LibraryExercise>> myLibrary = {};
  List<CustomRelic> myCustomRelics = [];

  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  void _initialLoad() {
    setState(() {
      myPlans = StorageService.loadPlans();
      myLogs = StorageService.loadLogs();
      myBodyData = StorageService.loadBodyData();
      myGoals = StorageService.loadGoals();
      myLibrary = StorageService.loadLibrary();
      myCustomRelics = StorageService.loadCustomRelics();
    });
  }

  void _refreshAndSave() {
    setState(() {
      StorageService.savePlans(myPlans);
      StorageService.saveLogs(myLogs);
      StorageService.saveBodyData(myBodyData);
      StorageService.saveGoals(myGoals);
      StorageService.saveLibrary(myLibrary);
      StorageService.saveCustomRelics(myCustomRelics);
    });
  }

  double _rawVal(dynamic v) => (v is num) ? v.toDouble() : 0.0;

  void _generateTitanID() {
    double w = _rawVal(myBodyData['weight']);
    double h = _rawVal(myBodyData['height']);
    double bf = _rawVal(myBodyData['bf']);
    double wrist = _rawVal(myBodyData['wrist']);

    double leanMass = w * (1 - (bf / 100.0));
    double ffmi = (h > 0) ? (leanMass / ((h / 100) * (h / 100))) + (6.3 * (1.8 - (h / 100))) : 0.0;
    double rRatio = (wrist > 0) ? h / wrist : 10.0;

    String combatClass = "THE GENESIS";
    Color classColor = Colors.white54;
    String chassis = rRatio > 10.4 ? "LIGHT" : rRatio >= 9.6 ? "STANDARD" : "HEAVY";

    if (ffmi >= 19.0) {
      combatClass = "THE TITAN";
      classColor = Colors.orangeAccent;
    }
    if (rRatio > 10.4 && ffmi > 21.0) {
      combatClass = "THE PEAK";
      classColor = Colors.cyanAccent;
    }
    if (rRatio < 9.6 && ffmi > 22.0) {
      combatClass = "THE HYBRID";
      classColor = Colors.redAccent;
    }

    double rarScore = ((rRatio - 10.0).abs() * 0.4 + (ffmi - 19.0).abs() * 0.1).clamp(0.1, 1.0);

    ExportService.generateAndShareId(
      context: context,
      bodyData: myBodyData,
      combatClass: combatClass,
      classColor: classColor,
      ffmi: ffmi,
      chassis: chassis,
      rarity: (rarScore * 100).toInt().toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> corePages = [
      const HomePage(),
      TreePage(
          plans: myPlans,
          logs: myLogs,
          goals: myGoals,
          library: myLibrary,
          onUpdate: _refreshAndSave
      ),
      HistoryPage(
          logs: myLogs,
          plans: myPlans,
          onUpdate: _refreshAndSave
      ),
      _buildHubMenu(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: corePages,
      ),
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

  Widget _buildHubMenu() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          const Text("TITAN", style: TextStyle(color: Colors.orangeAccent, letterSpacing: 8, fontSize: 10, fontWeight: FontWeight.bold)),
          const Text("COMMAND", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -2)),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: _generateTitanID,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.fingerprint, color: Colors.cyanAccent, size: 34),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ACCESS CREDENTIALS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(height: 2),
                        Text("GENERATE ASSET IDENTIFICATION CARD", style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _hubTile("ANALYTICS", Icons.analytics_outlined, Colors.orangeAccent,
                        () => _openPage(ProgressPage(logs: myLogs, plans: myPlans))),
                _hubTile("ROADMAPS", Icons.track_changes_rounded, Colors.blueAccent,
                        () => _openPage(ExpectedProgressPage(goals: myGoals, plans: myPlans, onUpdate: _refreshAndSave))),
                _hubTile("BODY STATS", Icons.person_search_rounded, Colors.greenAccent,
                        () => _openPage(MeasurementsPage(data: myBodyData, onUpdate: _refreshAndSave))),
                _hubTile("LIBRARY", Icons.book_rounded, Colors.purpleAccent,
                        () => _openPage(LibraryPage(library: myLibrary, onUpdate: _refreshAndSave))),
                _hubTile("EVOLUTION", Icons.accessibility_new_rounded, Colors.redAccent,
                        () => _openPage(BodyVisualizerPage(data: myBodyData, logs: myLogs))),
                _hubTile("RELIC VAULT", Icons.military_tech, Colors.amberAccent,
                        () => _openPage(RelicVaultPage(
                        logs: myLogs,
                        bodyData: myBodyData,
                        customRelics: myCustomRelics,
                        onUpdate: _refreshAndSave
                    ))),
              ],
            ),
          ),
        ],
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
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  void _openPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page)).then((_) => setState(() {}));
  }
}