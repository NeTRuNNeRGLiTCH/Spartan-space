import 'package:flutter/material.dart';
import '../models/workout_node.dart';
import '../models/workout_log.dart';
import '../models/goal_node.dart';
import '../widgets/workout_widgets.dart';
import 'session_complete_page.dart';

class WorkoutRoutine extends StatefulWidget {
  final WorkoutNode plan;
  final GoalNode? roadmap;
  final WorkoutNode? selectedDay;
  final List<WorkoutLog> logs;
  final VoidCallback onUpdate;
  final Function(WorkoutLog)? onLog;

  const WorkoutRoutine({
    super.key,
    required this.plan,
    this.roadmap,
    this.selectedDay,
    required this.logs,
    required this.onUpdate,
    this.onLog,
  });

  @override
  State<WorkoutRoutine> createState() => _WorkoutRoutineState();
}

class _WorkoutRoutineState extends State<WorkoutRoutine> {
  List<WorkoutNode> exercises = [];
  final TextEditingController _objectiveController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  void _initializeSession() {
    exercises.clear();
    if (widget.selectedDay != null) {
      _flatten(widget.selectedDay!, exercises);
    } else {
      _flatten(widget.plan, exercises);
    }
  }

  void _flatten(WorkoutNode node, List<WorkoutNode> list) {
    if (node.type == NodeType.leaf) {
      list.add(node);
    } else {
      for (var child in node.children) {
        _flatten(child, list);
      }
    }
  }

  void _initializeProtocol() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SessionCompletePage(
          title: widget.selectedDay?.title ?? widget.plan.title,
          dailyObjective: _objectiveController.text,
          exercises: exercises,
          logs: widget.logs,
          onUpdate: widget.onUpdate,
          onLog: widget.onLog,
          roadmap: widget.roadmap,
          rootSetRest: widget.plan.restTime ?? 90,
          rootInterRest: widget.plan.interExerciseRest,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Column(
        children: [
          RoutineHeader(title: widget.selectedDay?.title ?? widget.plan.title),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("SESSION DIRECTIVE",
                      style: TextStyle(color: Colors.orangeAccent, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _objectiveController,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      hintText: "DEFINE PRIMARY GOAL...",
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                var ex = exercises[index];
                return RoutineExerciseCard(
                  title: ex.title,
                  muscle: ex.muscleGroup ?? "GEN",
                  isRoadmap: widget.roadmap != null,
                  onManageLogic: () => _showProtocolManager(ex),
                  setRows: ex.sets.asMap().entries.map((entry) {
                    String unit = "R";
                    if (ex.trackingType == TrackingType.time) unit = "SEC";
                    if (ex.trackingType == TrackingType.distance) unit = "M";

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Text("${entry.key + 1}", style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(width: 15),
                          const Text("TARGET", style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.w900)),
                          const Spacer(),
                          _inlineEdit(entry.value.value.toString(), unit,
                                  (v) => setState(() => entry.value.value = int.tryParse(v) ?? 0)),
                          const SizedBox(width: 10),
                          if (ex.trackingType == TrackingType.weightReps)
                            _inlineEdit(entry.value.weight.toString(), "KG",
                                    (v) => setState(() => entry.value.weight = double.tryParse(v) ?? 0)),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: _initializeProtocol,
              child: const Text("INITIALIZE PROTOCOL",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inlineEdit(String val, String label, Function(String) onSave) {
    return InkWell(
      onTap: () {
        TextEditingController ctrl = TextEditingController(text: val);
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: Text("Adjust $label", style: const TextStyle(color: Colors.white, fontSize: 16)),
              content: TextField(
                controller: ctrl,
                autofocus: true,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
              ),
              actions: [TextButton(onPressed: () { onSave(ctrl.text); Navigator.pop(ctx); }, child: const Text("OK", style: TextStyle(color: Colors.orangeAccent)))],
            ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Text("$val $label", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  void _showProtocolManager(WorkoutNode ex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 25, right: 25, top: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("AUTOMATION STACK", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              ...ex.protocols.asMap().entries.map((e) => ListTile(
                title: Text(e.value.type.name.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                trailing: IconButton(icon: const Icon(Icons.close, size: 16, color: Colors.redAccent), onPressed: () => setSheetState(() => ex.protocols.removeAt(e.key))),
              )),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _addBtn(ex, ProtocolType.pyramidOverload, "Pyramid", setSheetState),
                    _addBtn(ex, ProtocolType.repRecovery, "Recovery", setSheetState),
                    _addBtn(ex, ProtocolType.plateauBreaker, "Plateau", setSheetState),
                    _addBtn(ex, ProtocolType.volumeKing, "Vol. King", setSheetState),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    ).then((_) => setState(() {}));
  }

  Widget _addBtn(WorkoutNode ex, ProtocolType type, String label, StateSetter setSheetState) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ActionChip(
          backgroundColor: Colors.white.withOpacity(0.05),
          label: Text(label, style: const TextStyle(fontSize: 10, color: Colors.white)),
          onPressed: () => _configProtocol(ex, type, label, () => setSheetState(() {}))),
    );
  }

  void _configProtocol(WorkoutNode ex, ProtocolType type, String label, VoidCallback onAdded) {
    TextEditingController c1 = TextEditingController(text: "12");
    TextEditingController c2 = TextEditingController(text: "5");
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: Text("Configure $label", style: const TextStyle(color: Colors.white, fontSize: 16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (type != ProtocolType.plateauBreaker)
            TextField(controller: c1, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Target Value", labelStyle: TextStyle(color: Colors.white38))),
          TextField(controller: c2, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: type == ProtocolType.repRecovery ? "Step Value" : "Weight Delta", labelStyle: const TextStyle(color: Colors.white38))),
        ],
      ),
      actions: [TextButton(onPressed: () {
        ex.protocols.add(WorkoutProtocol(type: type, targetValue: int.tryParse(c1.text) ?? 12, weightValue: double.tryParse(c2.text) ?? 5.0, stepValue: int.tryParse(c2.text) ?? 5));
        onAdded(); Navigator.pop(ctx);
      }, child: const Text("SAVE", style: TextStyle(color: Colors.orangeAccent)))],
    ));
  }
}