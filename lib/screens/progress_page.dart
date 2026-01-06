import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import '../models/workout_log.dart';
import '../models/workout_node.dart';
import '../widgets/progress_widgets.dart';

class ProgressPage extends StatefulWidget {
  final List<WorkoutLog> logs;
  final List<WorkoutNode> plans;

  const ProgressPage({super.key, required this.logs, required this.plans});

  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  int _viewType = 1;
  String? selectedExercise;
  DateTime currentCalendarMonth = DateTime.now();

  List<String> _getSortedExerciseNames() {
    Set<String> names = {};
    for (var log in widget.logs) names.add(log.exerciseName);
    void scan(WorkoutNode n) { if (n.type == NodeType.leaf) names.add(n.title); for (var c in n.children) scan(c); }
    for (var p in widget.plans) scan(p);
    return names.toList()..sort();
  }

  double _getPeakWeight(String name) {
    double peak = 0;
    var filtered = widget.logs.where((l) => l.exerciseName == name);
    for (var l in filtered) {
      for (var s in l.performedSets) { if (s.weight > peak) peak = s.weight; }
    }
    return peak;
  }

  @override
  Widget build(BuildContext context) {
    List<String> exercises = _getSortedExerciseNames();
    if (selectedExercise == null && exercises.isNotEmpty) selectedExercise = exercises.first;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(title: const Text("ANALYTICS", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 16)), centerTitle: true, backgroundColor: Colors.transparent),
      body: Column(
        children: [
          AnalyticsToggle(currentIndex: _viewType, onSelected: (i) => setState(() => _viewType = i)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildCurrentView(exercises),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView(List<String> exercises) {
    if (_viewType == 0) return _buildRecordsList(exercises);
    if (_viewType == 1) return _buildStrengthTimeline(exercises);
    return _buildActivityView();
  }

  Widget _buildRecordsList(List<String> exercises) {
    return Column(
      children: exercises.map((name) => RecordCard(title: name, weight: _getPeakWeight(name))).toList(),
    );
  }

  Widget _buildStrengthTimeline(List<String> exercises) {
    if (exercises.isEmpty) return const Center(child: Text("No Data Available"));

    var filteredLogs = widget.logs.where((l) => l.exerciseName == selectedExercise).toList();
    filteredLogs.sort((a, b) => a.date.compareTo(b.date));

    return Column(
      children: [
        DropdownButton<String>(
          value: selectedExercise,
          dropdownColor: const Color(0xFF111111),
          isExpanded: true,
          icon: const Icon(Icons.expand_more, color: Colors.orangeAccent),
          style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
          items: exercises.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => selectedExercise = v),
        ),
        const SizedBox(height: 20),
        NeonChartContainer(
          title: "Peak Weight Progression",
          chart: LineChart(_neonChartData(filteredLogs)),
        ),
      ],
    );
  }
  Widget _buildActivityView() {
    Map<String, int> muscleDist = {};
    for (var log in widget.logs) {
      if (log.muscleGroup != null) {
        muscleDist[log.muscleGroup!] = (muscleDist[log.muscleGroup!] ?? 0) + log.performedSets.length;
      }
    }

    return Column(
      children: [
        HeatMapCalendar(
          initDate: currentCalendarMonth,
          datasets: {for (var l in widget.logs) DateTime(l.date.year, l.date.month, l.date.day): 1},
          colorsets: {1: Colors.orangeAccent},
          defaultColor: Colors.white.withOpacity(0.05),
          textColor: Colors.white,
        ),
        const SizedBox(height: 30),
        const Text("MUSCLE VOLUME DISTRIBUTION", style: TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.white24)),
        const SizedBox(height: 15),
        MuscleFocusChart(distribution: muscleDist, getColor: _getMuscleColor),
        const SizedBox(height: 50),
      ],
    );
  }

  LineChartData _neonChartData(List<WorkoutLog> logs) {
    List<FlSpot> spots = [];
    for (int i = 0; i < logs.length; i++) {
      double peak = 0;
      for (var s in logs[i].performedSets) if (s.weight > peak) peak = s.weight;
      spots.add(FlSpot(i.toDouble(), peak));
    }
    if (spots.isEmpty) spots = [const FlSpot(0, 0)];

    return LineChartData(
      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.white.withOpacity(0.05))),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (v, m) {
            int i = v.toInt();
            if (i < 0 || i >= logs.length) return const Text("");
            return Text("${logs[i].date.day}/${logs[i].date.month}", style: const TextStyle(color: Colors.white10, fontSize: 9));
          },
        )),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.orangeAccent,
          barWidth: 4,
          shadow: Shadow(color: Colors.orangeAccent.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5)),
          belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [Colors.orangeAccent.withOpacity(0.2), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          dotData: FlDotData(show: true, getDotPainter: (s, p, b, i) => FlDotCirclePainter(radius: 4, color: const Color(0xFF050505), strokeWidth: 2, strokeColor: Colors.orangeAccent)),
        ),
      ],
    );
  }

  Color _getMuscleColor(String muscle) {
    Map<String, Color> colors = {"Chest": Colors.redAccent, "Back": Colors.blueAccent, "Legs": Colors.greenAccent, "Shoulders": Colors.orangeAccent, "Arms": Colors.purpleAccent, "Core": Colors.tealAccent};
    return colors[muscle] ?? Colors.grey;
  }
}