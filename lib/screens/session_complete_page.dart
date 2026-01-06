import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workout_node.dart';
import '../models/workout_log.dart';
import '../models/goal_node.dart';

class SessionCompletePage extends StatefulWidget {
  final String title;
  final String dailyObjective;
  final List<WorkoutNode> exercises;
  final List<WorkoutLog> logs;
  final VoidCallback onUpdate;
  final Function(WorkoutLog)? onLog;
  final GoalNode? roadmap;
  final int rootSetRest;
  final int rootInterRest;

  const SessionCompletePage({
    super.key,
    required this.title,
    required this.dailyObjective,
    required this.exercises,
    required this.logs,
    required this.onUpdate,
    required this.rootSetRest,
    required this.rootInterRest,
    this.onLog,
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
  Map<String, List<WorkoutSet>> _actualPerformance = {};

  @override
  void initState() {
    super.initState();
    for (var ex in widget.exercises) {
      _actualPerformance[ex.id] = [];
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showPerformanceInput(WorkoutNode ex, int setIndex) {
    final targetSet = ex.sets[setIndex];
    TextEditingController valCtrl = TextEditingController(text: targetSet.value.toString());
    TextEditingController weightCtrl = TextEditingController(text: targetSet.weight.toString());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text("LOG DATA: SET ${setIndex + 1}",
            style: const TextStyle(color: Colors.cyanAccent, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: valCtrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: ex.trackingType == TrackingType.time ? "Actual Seconds" : "Actual Reps/Distance",
                  labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
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
                    labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("ABORT", style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
            onPressed: () {
              final actual = WorkoutSet(
                value: int.tryParse(valCtrl.text) ?? 0,
                weight: double.tryParse(weightCtrl.text) ?? 0.0,
                isCompleted: true,
              );
              setState(() => _actualPerformance[ex.id]!.add(actual));
              Navigator.pop(ctx);
              bool isLastSet = setIndex == ex.sets.length - 1;
              bool hasMoreEx = _currentExIdx < widget.exercises.length - 1;
              if (isLastSet && hasMoreEx) {
                _startTimer(widget.rootInterRest, true);
              } else if (!isLastSet) {
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

  void _terminateSession() {
    _timer?.cancel();
    for (var ex in widget.exercises) {
      final actualSets = _actualPerformance[ex.id] ?? [];
      if (actualSets.isNotEmpty && widget.onLog != null) {
        widget.onLog!(WorkoutLog(
          date: DateTime.now(),
          exerciseName: ex.title,
          muscleGroup: ex.muscleGroup,
          performedSets: actualSets,
        ));
      }
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
              child: _isTimerActive
                  ? _buildTimerHUD()
                  : _buildExerciseFocusHUD(currentEx),
            ),
            _buildMainActionArea(currentEx),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("MISSION: ${widget.title.toUpperCase()}",
                  style: const TextStyle(color: Colors.white54, fontSize: 8, letterSpacing: 2, fontWeight: FontWeight.bold)),
              Text("PHASE ${_currentExIdx + 1}/${widget.exercises.length}",
                  style: const TextStyle(color: Colors.white54, fontSize: 8, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 5),
          Text(widget.dailyObjective.isEmpty ? "EXECUTE ASSIGNED PROTOCOL" : widget.dailyObjective.toUpperCase(),
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (_currentExIdx + 1) / widget.exercises.length,
            backgroundColor: Colors.white.withOpacity(0.1),
            color: Colors.orangeAccent,
            minHeight: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseFocusHUD(WorkoutNode ex) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(ex.muscleGroup?.toUpperCase() ?? "GENERAL",
              style: const TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 5)),
          const SizedBox(height: 10),
          Text(ex.title.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 40),
          ...ex.sets.asMap().entries.map((entry) {
            bool isCurrent = entry.key == _currentSetIdx;
            bool isDone = entry.key < _currentSetIdx;
            String unit = (ex.trackingType == TrackingType.time) ? "SEC" : "REPS";
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isCurrent ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isCurrent ? Colors.orangeAccent.withOpacity(0.5) : Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Text("${entry.key + 1}", style: TextStyle(color: isCurrent ? Colors.orangeAccent : Colors.white38, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 25),
                  Text("${entry.value.value} $unit",
                      style: TextStyle(color: isCurrent ? Colors.white : Colors.white54, fontWeight: FontWeight.w900, fontSize: 18)),
                  const Spacer(),
                  if (ex.trackingType == TrackingType.weightReps)
                    Text("${entry.value.weight} KG",
                        style: TextStyle(color: isCurrent ? Colors.white : Colors.white38, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  const SizedBox(width: 15),
                  Icon(isDone ? Icons.check_circle : (isCurrent ? Icons.bolt : Icons.radio_button_unchecked),
                      color: isDone ? Colors.greenAccent : (isCurrent ? Colors.orangeAccent : Colors.white24), size: 20),
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
        Icon(_isInterExerciseRest ? Icons.sync : Icons.timer_outlined,
            color: _isOvertime ? Colors.redAccent : Colors.cyanAccent, size: 45),
        const SizedBox(height: 20),
        Text(_isInterExerciseRest ? "INTER-MODULE RECOVERY" : "SYSTEM RECHARGE IN PROGRESS",
            style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
        Text(
          _secondsRemaining <= 0 ? "-${_secondsRemaining.abs()}" : _secondsRemaining.toString(),
          style: TextStyle(
              fontSize: 120,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              color: _isOvertime ? Colors.redAccent : Colors.white,
              letterSpacing: -5
          ),
        ),
        Text(_isOvertime ? "OVERTIME: COMMENCE TASK IMMEDIATELY" : "SECONDS REMAINING",
            style: TextStyle(color: _isOvertime ? Colors.redAccent : Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMainActionArea(WorkoutNode ex) {
    String label = _isTimerActive ? "I AM READY" : "LOG SET & REST";
    Color btnColor = _isTimerActive ? Colors.cyanAccent : Colors.orangeAccent;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              minimumSize: const Size(double.infinity, 80),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              elevation: 0,
            ),
            onPressed: () {
              if (_isTimerActive) {
                _onReadyPressed();
              } else {
                _showPerformanceInput(ex, _currentSetIdx);
              }
            },
            child: Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 20)),
          ),
          if (!_isTimerActive)
            TextButton(
              onPressed: _terminateSession,
              child: const Text("TERMINATE PROTOCOL",
                  style: TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.bold)),
            )
        ],
      ),
    );
  }

  Widget _buildStatusBar() => _buildTopStatus();
}