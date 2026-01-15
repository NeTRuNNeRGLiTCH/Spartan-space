import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:provider/provider.dart';
import '../models/workout_log.dart';
import '../widgets/progress_widgets.dart';
import '../controllers/progress_controller.dart';
import '../providers/titan_provider.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  late ProgressController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProgressController(
      provider: context.read<TitanProvider>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<TitanProvider>();
    final List<String> exercises = _controller.getSortedExerciseNames();

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
          title: const Text("ANALYTICS",
              style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 16)),
          centerTitle: true,
          backgroundColor: Colors.transparent
      ),
      body: Column(
        children: [
          AnalyticsToggle(
              currentIndex: _controller.viewType,
              onSelected: _controller.updateViewType
          ),
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
    return (_controller.viewType == 0)
        ? _buildRecordsList(exercises)
        : (_controller.viewType == 1)
        ? _buildStrengthTimeline(exercises)
        : _buildActivityView();
  }

  Widget _buildRecordsList(List<String> exercises) {
    return Column(
      children: exercises.map((name) => RecordCard(
          title: name,
          weight: _controller.getPeakWeight(name)
      )).toList(),
    );
  }

  Widget _buildStrengthTimeline(List<String> exercises) {
    if (exercises.isEmpty) return const Center(child: Text("No Data Available"));

    final filteredLogs = _controller.getFilteredLogsForSelectedExercise();

    return Column(
      children: [
        DropdownButton<String>(
          value: _controller.selectedExercise,
          dropdownColor: const Color(0xFF111111),
          isExpanded: true,
          icon: const Icon(Icons.expand_more, color: Colors.orangeAccent),
          style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
          items: exercises.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: _controller.updateSelectedExercise,
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
    return Column(
      children: [
        HeatMapCalendar(
          initDate: _controller.currentCalendarMonth,
          datasets: _controller.getHeatMapData(),
          colorsets: const {1: Colors.orangeAccent},
          defaultColor: Colors.white.withOpacity(0.05),
          textColor: Colors.white,
        ),
        const SizedBox(height: 30),
        const Text("MUSCLE VOLUME DISTRIBUTION",
            style: TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.white24)),
        const SizedBox(height: 15),
        MuscleFocusChart(
            distribution: _controller.getMuscleDistribution(),
            getColor: _controller.getMuscleColor
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  LineChartData _neonChartData(List<WorkoutLog> logs) {
    List<FlSpot> spots = [];
    for (int i = 0; i < logs.length; i++) {
      double peak = 0;
      for (var s in logs[i].performedSets) {
        if (s.weight > peak) peak = s.weight;
      }
      spots.add(FlSpot(i.toDouble(), peak));
    }
    if (spots.isEmpty) spots = [const FlSpot(0, 0)];

    return LineChartData(
      gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) => FlLine(color: Colors.white.withOpacity(0.05))
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (v, m) {
            int i = v.toInt();
            if (i < 0 || i >= logs.length) return const Text("");
            return Text("${logs[i].date.day}/${logs[i].date.month}",
                style: const TextStyle(color: Colors.white10, fontSize: 9));
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
          shadow: const Shadow(color: Colors.orangeAccent, blurRadius: 10, offset: Offset(0, 5)),
          belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                  colors: [Colors.orangeAccent.withOpacity(0.2), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter
              )
          ),
          dotData: FlDotData(
              show: true,
              getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0xFF050505),
                  strokeWidth: 2,
                  strokeColor: Colors.orangeAccent
              )
          ),
        ),
      ],
    );
  }
}