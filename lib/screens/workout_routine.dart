import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_node.dart';
import '../models/goal_node.dart';
import '../models/custom_protocol.dart';
import '../providers/titan_provider.dart';
import '../controllers/workout_routine_controller.dart';
import '../widgets/workout_widgets.dart';
import 'session_complete_page.dart';

class WorkoutRoutine extends StatefulWidget {
  final WorkoutNode plan;
  final GoalNode? roadmap;
  final WorkoutNode? selectedDay;

  const WorkoutRoutine({
    super.key,
    required this.plan,
    this.roadmap,
    this.selectedDay,
  });

  @override
  State<WorkoutRoutine> createState() => _WorkoutRoutineState();
}

class _WorkoutRoutineState extends State<WorkoutRoutine> {
  late WorkoutRoutineController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WorkoutRoutineController(
      provider: context.read<TitanProvider>(),
      plan: widget.plan,
      selectedDay: widget.selectedDay,
    );
  }

  void _initializeProtocol() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SessionCompletePage(
          title: widget.selectedDay?.title ?? widget.plan.title,
          dailyObjective: _controller.objectiveController.text,
          exercises: _controller.exercises,
          roadmap: widget.roadmap,
          rootSetRest: widget.plan.restTime ?? 90,
          rootInterRest: widget.plan.interExerciseRest,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<TitanProvider>();

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
                    controller: _controller.objectiveController,
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
              itemCount: _controller.exercises.length,
              itemBuilder: (context, index) {
                var ex = _controller.exercises[index];
                String unit = ex.trackingType == TrackingType.time ? "SEC" : (ex.trackingType == TrackingType.distance ? "METERS" : "R");

                return RoutineExerciseCard(
                  title: ex.title,
                  muscle: ex.muscleGroup ?? "GEN",
                  isRoadmap: widget.roadmap != null,
                  onManageLogic: () => _showProtocolManager(ex),
                  setRows: ex.sets.toList().asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Text("${entry.key + 1}", style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(width: 15),
                          const Text("TARGET", style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.w900)),
                          const Spacer(),
                          _inlineEdit("${entry.value.value}", unit, (v) => setState(() => _controller.updateSetTarget(entry.value, v, false))),
                          const SizedBox(width: 10),
                          if (ex.trackingType == TrackingType.weightReps)
                            _inlineEdit("${entry.value.weight}", "KG", (v) => setState(() => _controller.updateSetTarget(entry.value, v, true))),
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
    List<CustomProtocol> available = _controller.provider.service.getAllProtocols();
    CustomProtocol? current = ex.protocol.target;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("AUTOMATION STACK", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              DropdownButton<CustomProtocol>(
                value: available.any((p) => p.id == current?.id) ? available.firstWhere((p) => p.id == current?.id) : null,
                isExpanded: true,
                hint: const Text("Select TitanScript", style: TextStyle(color: Colors.white24)),
                dropdownColor: const Color(0xFF0A0A0A),
                items: available.map((p) => DropdownMenuItem(value: p, child: Text(p.title, style: const TextStyle(color: Colors.cyanAccent, fontSize: 13)))).toList(),
                onChanged: (val) => setSheetState(() => current = val),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, minimumSize: const Size(double.infinity, 50)),
                onPressed: () {
                  _controller.attachProtocol(ex, current);
                  Navigator.pop(ctx);
                },
                child: const Text("ATTACH SCRIPT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  _controller.clearProtocol(ex);
                  Navigator.pop(ctx);
                },
                child: const Text("CLEAR LOGIC", style: TextStyle(color: Colors.redAccent, fontSize: 10)),
              )
            ],
          ),
        ),
      ),
    );
  }
}