import 'dart:convert';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../models/workout_node.dart';
import '../models/workout_log.dart';
import '../models/goal_node.dart';
import '../models/relic.dart';

class StorageService {
  static final _box = Hive.box('gym_data');

  static void savePlans(List<WorkoutNode> plans) {
    List<String> encoded = plans.map((p) => jsonEncode(p.toJson())).toList();
    _box.put('my_plans', encoded);
  }

  static List<WorkoutNode> loadPlans() {
    List<dynamic>? data = _box.get('my_plans');
    if (data == null) return [];
    return data.map((p) => WorkoutNode.fromJson(jsonDecode(p))).toList();
  }

  static void saveLogs(List<WorkoutLog> logs) {
    List<String> encoded = logs.map((l) => jsonEncode(l.toJson())).toList();
    _box.put('my_logs', encoded);
  }

  static List<WorkoutLog> loadLogs() {
    List<dynamic>? data = _box.get('my_logs');
    if (data == null) return [];
    return data.map((l) => WorkoutLog.fromJson(jsonDecode(l))).toList();
  }

  static void saveBodyData(Map<String, dynamic> data) {
    _box.put('body_measurements', jsonEncode(data));
  }

  static Map<String, dynamic> loadBodyData() {
    String? data = _box.get('body_measurements');
    if (data == null) return {};
    return jsonDecode(data);
  }

  static void saveGoals(List<GoalNode> goals) {
    List<String> encoded = goals.map((g) => jsonEncode(g.toJson())).toList();
    _box.put('my_goals', encoded);
  }

  static List<GoalNode> loadGoals() {
    List<dynamic>? data = _box.get('my_goals');
    if (data == null) return [];
    return data.map((g) => GoalNode.fromJson(jsonDecode(g))).toList();
  }

  static void saveCustomRelics(List<CustomRelic> relics) {
    List<String> encoded = relics.map((r) => jsonEncode(r.toJson())).toList();
    _box.put('custom_relics', encoded);
  }

  static List<CustomRelic> loadCustomRelics() {
    List<dynamic>? data = _box.get('custom_relics');
    if (data == null) return [];
    return data.map((r) => CustomRelic.fromJson(jsonDecode(r))).toList();
  }

  static void saveLibrary(Map<String, List<LibraryExercise>> library) {
    Map<String, dynamic> jsonMap = library.map(
            (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList())
    );
    _box.put('exercise_library_v2', jsonEncode(jsonMap));
  }

  static Map<String, List<LibraryExercise>> loadLibrary() {
    String? data = _box.get('exercise_library_v2');

    if (data == null) {
      return {
        "Chest": [
          LibraryExercise(name: "Flat Barbell Bench Press", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Incline Dumbbell Press", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Decline Bench Press", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Chest Flyes (Dumbbell)", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Cable Crossovers", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Dips (Chest Focus)", trackingType: TrackingType.repsOnly),
          LibraryExercise(name: "Pushups", trackingType: TrackingType.repsOnly),
          LibraryExercise(name: "Machine Chest Press", trackingType: TrackingType.weightReps)
        ],
        "Back": [
          LibraryExercise(name: "Deadlift", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Pull Ups", trackingType: TrackingType.repsOnly),
          LibraryExercise(name: "Bent Over Barbell Rows", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Lat Pulldowns", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Seated Cable Rows", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Face Pulls", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "T-Bar Rows", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Single Arm Dumbbell Row", trackingType: TrackingType.weightReps)
        ],
        "Legs": [
          LibraryExercise(name: "Barbell Back Squat", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Leg Press", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Leg Extensions", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Leg Curls (Seated/Lying)", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Walking Lunges", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Hack Squat", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Bulgarian Split Squat", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Goblet Squats", trackingType: TrackingType.weightReps)
        ],
        "Shoulders": [
          LibraryExercise(name: "Overhead Press (Military)", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Lateral Raises", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Front Raises", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Rear Delt Flyes", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Arnold Press", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Upright Rows", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Dumbbell Shrugs", trackingType: TrackingType.weightReps)
        ],
        "Arms": [
          LibraryExercise(name: "Barbell Bicep Curls", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Hammer Curls", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Tricep Pushdowns (Cable)", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Skullcrushers", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Preacher Curls", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Concentration Curls", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Overhead Tricep Extension", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Dips (Tricep Focus)", trackingType: TrackingType.repsOnly)
        ],
        "Glutes": [
          LibraryExercise(name: "Barbell Hip Thrusts", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Glute Bridges", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Romanian Deadlift", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Glute Kickbacks (Cable)", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Sumo Squats", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Step-ups", trackingType: TrackingType.weightReps)
        ],
        "Calves": [
          LibraryExercise(name: "Standing Calf Raises", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Seated Calf Raises", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Donkey Calf Raises", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Leg Press Calf Raises", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Tibialis Raises", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Single Leg Calf Raise", trackingType: TrackingType.weightReps)
        ],
        "Neck": [
          LibraryExercise(name: "Neck Extension (Harness)", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Neck Flexion (Plate Lying)", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Lateral Neck Flexion", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Isometric Neck Holds", trackingType: TrackingType.time)
        ],
        "Core": [
          LibraryExercise(name: "Plank", trackingType: TrackingType.time),
          LibraryExercise(name: "Hanging Leg Raises", trackingType: TrackingType.repsOnly),
          LibraryExercise(name: "Russian Twists", trackingType: TrackingType.repsOnly),
          LibraryExercise(name: "Bicycle Crunches", trackingType: TrackingType.repsOnly),
          LibraryExercise(name: "Cable Woodchoppers", trackingType: TrackingType.weightReps),
          LibraryExercise(name: "Dead Bug", trackingType: TrackingType.time),
          LibraryExercise(name: "Ab Wheel Rollouts", trackingType: TrackingType.repsOnly)
        ],
        "Cardio": [
          LibraryExercise(name: "Running (Treadmill)", trackingType: TrackingType.distance),
          LibraryExercise(name: "Cycling", trackingType: TrackingType.distance),
          LibraryExercise(name: "Jump Rope", trackingType: TrackingType.time),
          LibraryExercise(name: "Rowing Machine", trackingType: TrackingType.distance),
          LibraryExercise(name: "Stairclimber", trackingType: TrackingType.time),
          LibraryExercise(name: "Burpees", trackingType: TrackingType.repsOnly)
        ]
      };
    }

    Map<String, dynamic> decoded = jsonDecode(data);
    return decoded.map((key, value) => MapEntry(
        key,
        (value as List).map((e) => LibraryExercise.fromJson(e)).toList()
    ));
  }
}