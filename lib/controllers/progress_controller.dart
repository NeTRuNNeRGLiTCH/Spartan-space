import 'package:flutter/material.dart';
import '../models/workout_log.dart';
import '../models/workout_node.dart';
import '../providers/titan_provider.dart';

class ProgressController {
  final TitanProvider provider;

  int viewType = 1;
  String? selectedExercise;
  DateTime currentCalendarMonth = DateTime.now();

  ProgressController({
    required this.provider,
  }) {
    final exercises = getSortedExerciseNames();
    if (selectedExercise == null && exercises.isNotEmpty) {
      selectedExercise = exercises.first;
    }
  }

  void updateViewType(int type) {
    viewType = type;
    provider.refreshAll();
  }

  void updateSelectedExercise(String? exercise) {
    selectedExercise = exercise;
    provider.refreshAll();
  }

  List<String> getSortedExerciseNames() {
    Set<String> names = {};

    for (var log in provider.logs) {
      names.add(log.exerciseName);
    }

    void scan(WorkoutNode n) {
      if (n.type == NodeType.leaf) names.add(n.title);
      for (var c in n.children) {
        scan(c);
      }
    }

    for (var p in provider.plans) {
      scan(p);
    }

    return names.toList()..sort();
  }

  double getPeakWeight(String name) {
    double peak = 0;
    final filtered = provider.logs.where((l) => l.exerciseName == name);
    for (var l in filtered) {
      for (var s in l.performedSets) {
        if (s.weight > peak) peak = s.weight;
      }
    }
    return peak;
  }

  Map<String, int> getMuscleDistribution() {
    Map<String, int> muscleDist = {};
    for (var log in provider.logs) {
      if (log.muscleGroup != null) {
        muscleDist[log.muscleGroup!] = (muscleDist[log.muscleGroup!] ?? 0) + log.performedSets.length;
      }
    }
    return muscleDist;
  }

  List<WorkoutLog> getFilteredLogsForSelectedExercise() {
    final filtered = provider.logs.where((l) => l.exerciseName == selectedExercise).toList();
    return filtered..sort((a, b) => a.date.compareTo(b.date));
  }

  Color getMuscleColor(String muscle) {
    const Map<String, Color> colors = {
      "Chest": Colors.redAccent,
      "Back": Colors.blueAccent,
      "Legs": Colors.greenAccent,
      "Shoulders": Colors.orangeAccent,
      "Arms": Colors.purpleAccent,
      "Core": Colors.tealAccent,
      "Glutes": Colors.pinkAccent,
      "Calves & Neck": Colors.brown,
      "Cardio": Colors.yellowAccent,
    };
    return colors[muscle] ?? Colors.grey;
  }

  Map<DateTime, int> getHeatMapData() {
    return {
      for (var l in provider.logs)
        DateTime(l.date.year, l.date.month, l.date.day): 1
    };
  }
}