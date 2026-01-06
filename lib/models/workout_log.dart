import 'workout_node.dart';

class WorkoutLog {
  final DateTime date;
  final String exerciseName;
  final String? muscleGroup;
  final List<WorkoutSet> performedSets;

  WorkoutLog({
    required this.date,
    required this.exerciseName,
    this.muscleGroup,
    required this.performedSets,
  });
  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'exerciseName': exerciseName,
    'muscleGroup': muscleGroup,
    'performedSets': performedSets.map((e) => e.toJson()).toList(),
  };
  factory WorkoutLog.fromJson(Map<dynamic, dynamic> json) => WorkoutLog(
    date: DateTime.parse(json['date']),
    exerciseName: json['exerciseName'],
    muscleGroup: json['muscleGroup'],
    performedSets: (json['performedSets'] as List)
        .map((e) => WorkoutSet.fromJson(e))
        .toList(),
  );
}