import 'dart:async';
import 'package:flutter/services.dart';
import '../models/workout_node.dart';
import '../models/workout_log.dart';
import '../models/goal_node.dart';
import '../services/titan_engine/titan_engine.dart';
import '../providers/titan_provider.dart';

class SessionController {
  final List<WorkoutNode> exercises;
  final TitanProvider provider;
  final GoalNode? roadmap;
  final int rootSetRest;
  final int rootInterRest;

  int currentExIdx = 0;
  int currentSetIdx = 0;
  int secondsRemaining = 0;
  bool isTimerActive = false;
  bool isOvertime = false;
  bool isInterExerciseRest = false;
  bool isSessionComplete = false;

  Timer? _timer;
  final Map<String, List<WorkoutSet>> actualPerformance = {};

  SessionController({
    required this.exercises,
    required this.provider,
    required this.rootSetRest,
    required this.rootInterRest,
    this.roadmap,
  }) {
    for (var ex in exercises) {
      actualPerformance[ex.id.toString()] = [];
    }
  }

  void dispose() {
    _timer?.cancel();
  }

  void logSetPerformance(WorkoutNode ex, int val, double weight) {
    final actual = WorkoutSet()
      ..value = val
      ..weight = weight
      ..isCompleted = true;

    actualPerformance[ex.id.toString()]!.add(actual);

    bool isLastSetOfEx = currentSetIdx == ex.sets.length - 1;
    bool hasMoreExercises = currentExIdx < exercises.length - 1;

    if (isLastSetOfEx) {
      if (hasMoreExercises) {
        startTimer(rootInterRest, true);
      } else {
        isSessionComplete = true;
        provider.refreshAll();
      }
    } else {
      startTimer(ex.restTime ?? rootSetRest, false);
    }
  }

  void startTimer(int seconds, bool isExerciseChange) {
    _timer?.cancel();
    secondsRemaining = seconds;
    isTimerActive = true;
    isOvertime = false;
    isInterExerciseRest = isExerciseChange;
    provider.refreshAll();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      secondsRemaining--;
      if (secondsRemaining <= 0) {
        if (!isOvertime) {
          isOvertime = true;
          HapticFeedback.vibrate();
        }
        if (secondsRemaining % 5 == 0) HapticFeedback.heavyImpact();
      }
      provider.refreshAll();
    });
  }

  void skipTimer() {
    _timer?.cancel();
    isTimerActive = false;
    if (isInterExerciseRest) {
      currentExIdx++;
      currentSetIdx = 0;
    } else {
      currentSetIdx++;
    }
    provider.refreshAll();
  }

  Future<void> saveAndClose(Function onComplete) async {
    _timer?.cancel();

    for (var ex in exercises) {
      final actuals = actualPerformance[ex.id.toString()] ?? [];
      if (actuals.isEmpty) continue;

      final log = WorkoutLog()
        ..date = DateTime.now()
        ..exerciseName = ex.title
        ..muscleGroup = ex.muscleGroup;
      log.performedSets.addAll(actuals);
      provider.saveLog(log);

      if (ex.protocol.target != null) {
        final nextSessionSets = TitanEngine.execute(
          protocol: ex.protocol.target!,
          actualPerformance: actuals,
          service: provider.service,
        );
        ex.sets.clear();
        ex.sets.addAll(nextSessionSets);
      }
      provider.service.savePlan(ex);
    }

    provider.refreshAll();
    onComplete();
  }

  WorkoutNode get currentExercise => exercises[currentExIdx];
  double get sessionProgress => (currentExIdx + 1) / exercises.length;
}