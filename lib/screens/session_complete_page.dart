import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workout_node.dart';
import '../models/workout_log.dart';
import '../models/goal_node.dart';
import '../services/objectbox_service.dart';
import '../services/titan_engine.dart';

class SessionCompletePage extends StatefulWidget {
  final String title;
  final String dailyObjective;
  final List<WorkoutNode> exercises;
  final ObjectBoxService service;
  final VoidCallback onUpdate;
  final GoalNode? roadmap;
  final int rootSetRest;
  final int rootInterRest;

  const SessionCompletePage({
    super.key,
    required this.title,
    required this.dailyObjective,
    required this.exercises,
    required this.service,
    required this.onUpdate,
    required this.rootSetRest,
    required this.rootInterRest,
    this.roadmap,
  });

  @override
  State<SessionCompletePage> createState() => _SessionCompletePageState();
}

class _SessionCompletePageState extends State<SessionCompletePage> {
  int _currentExIdx = 0;
  int _currentSetIdx = 0;
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isTimerActive = false;
  bool _isOvertime = false;
  bool _isInterExerciseRest = false;

  final Map<String, List<WorkoutSet>> _actualPerformance = {};

  @override
  void initState() {
    super.initState();
    for (var ex in widget.exercises) {
      _actualPerformance[ex.id.toString()] = [];
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showPerformanceInput(WorkoutNode ex, int setIndex) {
    final setsList = ex.sets.toList();
    final targetSet = setsList[setIndex];

    TextEditingController valCtrl = TextEditingController(text: targetSet.value.toString());
    TextEditingController weightCtrl = TextEditingController(text: targetSet.weight.toString());

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
                labelText: ex.trackingType == TrackingType.time ? "Actual Seconds" : "Actual Reps",
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
              final actual = WorkoutSet()
                ..value = int.tryParse(valCtrl.text) ?? 0
                ..weight = double.tryParse(weightCtrl.text) ?? 0.0
                ..isCompleted = true;

              setState(() => _actualPerformance[ex.id.toString()]!.add(actual));
              Navigator.pop(ctx);

              bool isLastSetOfExercise = setIndex == setsList.length - 1;
              bool hasMoreExercises = _currentExIdx < widget.exercises.length - 1;

              if (isLastSetOfExercise && hasMoreExercises) {
                _startTimer(widget.rootInterRest, true);
              } else if (!isLastSetOfExercise) {
                int restToUse = ex.restTime ?? widget.rootSetRest;
                _startTimer(restToUse, false);
              } else {
                _terminateSession();
              }
            },
            child: const Text("LOG & RECHARGE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _startTimer(int seconds, bool isExerciseChange) {
    setState(() {
      _secondsRemaining = seconds;
      _isTimerActive = true;
      _isOvertime = false;
      _isInterExerciseRest = isExerciseChange;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsRemaining--;
        if (_secondsRemaining <= 0) {
          if (!_isOvertime) {
            _isOvertime = true;
            HapticFeedback.vibrate();
          }
          if (_secondsRemaining % 5 == 0) HapticFeedback.heavyImpact();
        }
      });
    });
  }

  void _onReadyPressed() {
    _timer?.cancel();
    setState(() {
      _isTimerActive = false;
      if (_isInterExerciseRest) {
        _currentExIdx++;
        _currentSetIdx = 0;
      } else {
        _currentSetIdx++;
      }
    });
  }

  Future<void> _terminateSession() async {
    _timer?.cancel();

    for (var ex in widget.exercises) {
      final actuals = _actualPerformance[ex.id.toString()] ?? [];
      if (actuals.isEmpty) continue;

      final log = WorkoutLog()
        ..date = DateTime.now()
        ..exerciseName = ex.title
        ..muscleGroup = ex.muscleGroup;
      log.performedSets.addAll(actuals);
      widget.service.saveLog(log);

      if (ex.protocol.target != null) {
        final nextSessionSets = TitanEngine.execute(
          protocol: ex.protocol.target!,
          actualPerformance: actuals,
          protocolBox: widget.service.protocolBox,
        );

        ex.sets.clear();
        ex.sets.addAll(nextSessionSets);
      }

      widget.service.savePlan(ex);
    }

    widget.onUpdate();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentEx = widget.exercises[_currentExIdx];
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Column(
          children: [
            _buildStatusBar(),
            Expanded(
              child: _isTimerActive ? _buildTimerHUD() : _buildExerciseFocusHUD(currentEx),
            ),
            _buildMainActionArea(currentEx),
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
              Text("PHASE ${_currentExIdx + 1}/${widget.exercises.length}", style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 5),
          Text(widget.dailyObjective.isEmpty ? "EXECUTE ASSIGNED PROTOCOL" : widget.dailyObjective.toUpperCase(),
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
              value: (_currentExIdx + 1) / widget.exercises.length,
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
            bool isCurrent = entry.key == _currentSetIdx;
            bool isDone = entry.key < _currentSetIdx;
            String unit = (ex.trackingType == TrackingType.time) ? "SEC" : "REPS";
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
        Icon(_isInterExerciseRest ? Icons.sync : Icons.shutter_speed_outlined,
            color: _isOvertime ? Colors.redAccent : Colors.cyanAccent, size: 50),
        const SizedBox(height: 20),
        Text(_isInterExerciseRest ? "TRANSITION RECOVERY" : "SYSTEM RECHARGE",
            style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 4, fontWeight: FontWeight.bold)),
        Text(
          _secondsRemaining <= 0 ? "-${_secondsRemaining.abs()}" : _secondsRemaining.toString(),
          style: TextStyle(fontSize: 130, fontWeight: FontWeight.w900, fontFamily: 'monospace', color: _isOvertime ? Colors.redAccent : Colors.white),
        ),
        Text(_isOvertime ? "OVERTIME DETECTED" : "SECONDS REMAINING",
            style: TextStyle(color: _isOvertime ? Colors.redAccent : Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMainActionArea(WorkoutNode ex) {
    String label = _isTimerActive ? "INITIATE PHASE" : "LOG & RECHARGE";
    Color btnColor = _isTimerActive ? Colors.cyanAccent : Colors.orangeAccent;
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
            onPressed: () => _isTimerActive ? _onReadyPressed() : _showPerformanceInput(ex, _currentSetIdx),
            child: Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 18)),
          ),
          if (!_isTimerActive)
            TextButton(
              onPressed: _terminateSession,
              child: const Text("TERMINATE MISSION", style: TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.bold)),
            )
        ],
      ),
    );
  }
}