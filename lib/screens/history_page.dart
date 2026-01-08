import 'package:flutter/material.dart';
import '../models/workout_log.dart';
import '../models/workout_node.dart';
import '../services/objectbox_service.dart';
import '../widgets/history_widgets.dart';

class HistoryPage extends StatefulWidget {
  final ObjectBoxService service;
  final List<WorkoutNode> plans;
  final VoidCallback onUpdate;

  const HistoryPage({
    super.key,
    required this.service,
    required this.plans,
    required this.onUpdate
  });

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late PageController _pageController;

  static const int calendarOrigin = 10000;
  int _currentPageIndex = calendarOrigin;
  String? selectedFolderFilter;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  Widget build(BuildContext context) {
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
            planTitles: widget.plans.map((p) => p.title).toList(),
            selectedPlan: selectedFolderFilter,
            onSelected: (val) => setState(() => selectedFolderFilter = val),
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPageIndex = index),
        itemBuilder: (context, index) {
          DateTime date = DateTime.now().add(Duration(days: index - calendarOrigin));
          return _buildDailyLogView(date);
        },
      ),
    );
  }

  Widget _buildDailyLogView(DateTime date) {
    List<WorkoutLog> dayLogs = widget.service.getLogsForDay(date);

    bool isToday = date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;

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
              var log = dayLogs[i];
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
    List<WorkoutSet> tempSets = log.performedSets.toList().map((s) =>
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
                setState(() {
                  log.performedSets.clear();
                  log.performedSets.addAll(tempSets);
                  widget.service.saveLog(log);
                });
                widget.onUpdate();
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
              setState(() {
                widget.service.deleteLog(logToDelete.id);
              });
              widget.onUpdate();
              Navigator.pop(ctx);
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}