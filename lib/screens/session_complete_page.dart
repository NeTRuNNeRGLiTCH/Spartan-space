import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_node.dart';
import '../models/goal_node.dart';
import '../controllers/session_controller.dart';
import '../providers/titan_provider.dart';

class SessionCompletePage extends StatefulWidget {
  final String title;
  final String dailyObjective;
  final List<WorkoutNode> exercises;
  final GoalNode? roadmap;
  final int rootSetRest;
  final int rootInterRest;

  const SessionCompletePage({
    super.key,
    required this.title,
    required this.dailyObjective,
    required this.exercises,
    required this.rootSetRest,
    required this.rootInterRest,
    this.roadmap,
  });

  @override
  State<SessionCompletePage> createState() => _SessionCompletePageState();
}

class _SessionCompletePageState extends State<SessionCompletePage> {
  late SessionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SessionController(
      exercises: widget.exercises,
      provider: context.read<TitanProvider>(),
      rootSetRest: widget.rootSetRest,
      rootInterRest: widget.rootInterRest,
      roadmap: widget.roadmap,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showPerformanceInput(WorkoutNode ex, int setIndex) {
    final targetSet = ex.sets.toList()[setIndex];
    final valCtrl = TextEditingController(text: targetSet.value.toString());
    final weightCtrl = TextEditingController(text: targetSet.weight.toString());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text("LOG DATA: SET ${setIndex + 1}",
            style: const TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: valCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: ex.trackingType == TrackingType.time ? "Actual Seconds" : "Actual Units",
                labelStyle: const TextStyle(color: Colors.white54, fontSize: 10),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
              ),
            ),
            if (ex.trackingType == TrackingType.weightReps)
              TextField(
                controller: weightCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Actual Weight (kg)",
                  labelStyle: TextStyle(color: Colors.white54, fontSize: 10),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("ABORT", style: TextStyle(color: Colors.white24))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
            onPressed: () {
              final val = int.tryParse(valCtrl.text) ?? 0;
              final weight = double.tryParse(weightCtrl.text) ?? 0.0;
              Navigator.pop(ctx);
              setState(() => _controller.logSetPerformance(ex, val, weight));
            },
            child: const Text("LOG & RECHARGE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<TitanProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Column(
          children: [
            _buildStatusBar(),
            Expanded(
              child: _controller.isTimerActive
                  ? _buildTimerHUD()
                  : _buildExerciseFocusHUD(_controller.currentExercise),
            ),
            _buildMainActionArea(_controller.currentExercise),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("MISSION: ${widget.title.toUpperCase()}", style: const TextStyle(color: Colors.white30, fontSize: 8, letterSpacing: 2, fontWeight: FontWeight.bold)),
              Text("PHASE ${_controller.currentExIdx + 1}/${widget.exercises.length}", style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 5),
          Text(widget.dailyObjective.isEmpty ? "EXECUTE ASSIGNED PROTOCOL" : widget.dailyObjective.toUpperCase(),
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
              value: _controller.sessionProgress,
              backgroundColor: Colors.white.withOpacity(0.05),
              color: Colors.orangeAccent,
              minHeight: 2
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseFocusHUD(WorkoutNode ex) {
    final sets = ex.sets.toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Text(ex.muscleGroup?.toUpperCase() ?? "GENERAL", style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 5)),
          const SizedBox(height: 10),
          Text(ex.title.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 40),
          ...sets.asMap().entries.map((entry) {
            final isCurrent = entry.key == _controller.currentSetIdx;
            final isDone = entry.key < _controller.currentSetIdx || (entry.key == _controller.currentSetIdx && _controller.isSessionComplete);
            final unit = (ex.trackingType == TrackingType.time) ? "SEC" : "REPS";

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: isCurrent ? Colors.white.withOpacity(0.07) : Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isCurrent ? Colors.orangeAccent.withOpacity(0.4) : Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Text("${entry.key + 1}", style: TextStyle(color: isCurrent ? Colors.orangeAccent : Colors.white24, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 25),
                  Text("${entry.value.value} $unit", style: TextStyle(color: isCurrent ? Colors.white : Colors.white38, fontWeight: FontWeight.w900, fontSize: 18)),
                  const Spacer(),
                  if (ex.trackingType == TrackingType.weightReps)
                    Text("${entry.value.weight} KG", style: TextStyle(color: isCurrent ? Colors.white : Colors.white24, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  const SizedBox(width: 15),
                  Icon(isDone ? Icons.check_circle : (isCurrent ? Icons.bolt : Icons.radio_button_unchecked),
                      color: isDone ? Colors.greenAccent : (isCurrent ? Colors.orangeAccent : Colors.white12), size: 18),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimerHUD() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(_controller.isInterExerciseRest ? Icons.sync : Icons.shutter_speed_outlined,
            color: _controller.isOvertime ? Colors.redAccent : Colors.cyanAccent, size: 50),
        const SizedBox(height: 20),
        Text(_controller.isInterExerciseRest ? "TRANSITION RECOVERY" : "SYSTEM RECHARGE",
            style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 4, fontWeight: FontWeight.bold)),
        Text(
          _controller.secondsRemaining <= 0 ? "-${_controller.secondsRemaining.abs()}" : _controller.secondsRemaining.toString(),
          style: TextStyle(
              fontSize: 130,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              color: _controller.isOvertime ? Colors.redAccent : Colors.white
          ),
        ),
        Text(_controller.isOvertime ? "OVERTIME DETECTED" : "SECONDS REMAINING",
            style: TextStyle(color: _controller.isOvertime ? Colors.redAccent : Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMainActionArea(WorkoutNode ex) {
    final label = _controller.isSessionComplete ? "FINISH MISSION" : (_controller.isTimerActive ? "INITIATE PHASE" : "LOG & RECHARGE");
    final btnColor = _controller.isSessionComplete ? Colors.greenAccent : (_controller.isTimerActive ? Colors.cyanAccent : Colors.orangeAccent);

    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              minimumSize: const Size(double.infinity, 80),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            onPressed: () {
              if (_controller.isSessionComplete) {
                _controller.saveAndClose(() => Navigator.of(context).pop());
              } else if (_controller.isTimerActive) {
                _controller.skipTimer();
              } else {
                _showPerformanceInput(ex, _controller.currentSetIdx);
              }
            },
            child: Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 18)),
          ),
          if (!_controller.isTimerActive && !_controller.isSessionComplete)
            TextButton(
              onPressed: () => _controller.saveAndClose(() => Navigator.of(context).pop()),
              child: const Text("TERMINATE MISSION", style: TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.bold)),
            )
        ],
      ),
    );
  }
}