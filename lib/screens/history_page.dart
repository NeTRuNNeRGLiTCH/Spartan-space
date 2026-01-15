import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_log.dart';
import '../models/workout_node.dart';
import '../widgets/history_widgets.dart';
import '../controllers/history_controller.dart';
import '../providers/titan_provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late HistoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HistoryController(
      provider: context.read<TitanProvider>(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<TitanProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        title: const Text("TRAINING ARCHIVE",
            style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: HistoryPlanFilter(
            planTitles: _controller.planTitles,
            selectedPlan: _controller.selectedPlanFilter,
            onSelected: _controller.updatePlanFilter,
          ),
        ),
      ),
      body: PageView.builder(
        controller: _controller.pageController,
        onPageChanged: _controller.updatePageIndex,
        itemBuilder: (context, index) {
          final DateTime date = _controller.getDateFromIndex(index);
          return _buildDailyLogView(date);
        },
      ),
    );
  }

  Widget _buildDailyLogView(DateTime date) {
    final List<WorkoutLog> dayLogs = _controller.getLogsForDate(date);
    final bool isToday = _controller.isToday(date);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            isToday ? "TODAY" : "${date.day}/${date.month}/${date.year}",
            style: const TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 1
            ),
          ),
        ),
        Expanded(
          child: dayLogs.isEmpty
              ? const Center(
              child: Text("NO DATA RECORDED",
                  style: TextStyle(color: Colors.white38, letterSpacing: 2, fontSize: 12)))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: dayLogs.length,
            itemBuilder: (context, i) {
              final log = dayLogs[i];
              return HistoryLogCard(
                title: log.exerciseName,
                onEdit: () => _showEditLogDialog(log),
                onDelete: () => _confirmDeleteLog(log),
                setRows: log.performedSets.toList().asMap().entries.map((entry) => ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  leading: Text("${entry.key + 1}",
                      style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                  title: Text("${entry.value.value} Units",
                      style: const TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500)),
                  trailing: Text(entry.value.weight > 0 ? "${entry.value.weight} kg" : "--",
                      style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                )).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showEditLogDialog(WorkoutLog log) {
    final List<WorkoutSet> tempSets = log.performedSets.toList().map((s) =>
        WorkoutSet(value: s.value, weight: s.weight, isCompleted: s.isCompleted)).toList();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text("CORRECT ${log.exerciseName.toUpperCase()}",
              style: const TextStyle(fontSize: 12, color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: tempSets.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Reps/Sec",
                            labelStyle: TextStyle(color: Colors.white54),
                          ),
                          controller: TextEditingController(text: entry.value.value.toString()),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          onChanged: (v) => entry.value.value = int.tryParse(v) ?? 0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "kg",
                            labelStyle: TextStyle(color: Colors.white54),
                          ),
                          controller: TextEditingController(text: entry.value.weight.toString()),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          onChanged: (v) => entry.value.weight = double.tryParse(v) ?? 0,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("CANCEL", style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                _controller.updateLog(log, tempSets);
                Navigator.pop(ctx);
              },
              child: const Text("UPDATE", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteLog(WorkoutLog logToDelete) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("WIPE DATA?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("This entry will be permanently removed from the training archive.",
            style: TextStyle(color: Colors.white70, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL", style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              _controller.deleteLog(logToDelete.id);
              Navigator.pop(ctx);
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}