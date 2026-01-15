import 'dart:async';
import 'package:flutter/material.dart';
import '../models/workout_node.dart';
import '../models/workout_log.dart';
import '../models/goal_node.dart';
import '../models/relic.dart';
import '../services/objectbox_service.dart';
import '../services/library_service.dart';

class TitanProvider extends ChangeNotifier {
  final ObjectBoxService service;

  List<WorkoutNode> _plans = [];
  List<WorkoutLog> _activeLogs = [];
  List<WorkoutLog> _archiveLogs = [];
  List<GoalNode> _goals = [];
  Map<String, List<LibraryExercise>> _library = {};
  final Map<String, dynamic> _bodyData = {};
  final List<CustomRelic> _customRelics = [];

  Timer? _deloadTimer;
  bool _isSyncing = false;

  TitanProvider({required this.service}) {
    refreshAll();
  }

  List<WorkoutNode> get plans => _plans;

  List<WorkoutLog> get logs => [..._activeLogs, ..._archiveLogs];

  bool get isArchiveActive => _archiveLogs.isNotEmpty;
  bool get isSyncing => _isSyncing;
  List<GoalNode> get goals => _goals;
  Map<String, List<LibraryExercise>> get library => _library;
  Map<String, dynamic> get bodyData => _bodyData;
  List<CustomRelic> get customRelics => _customRelics;

  Future<void> refreshAll() async {
    _plans = service.loadPlans();
    _activeLogs = service.getRecentLogs(31);
    _goals = service.loadGoals();

    final Map<String, List<LibraryExercise>> fullMap = LibraryService.getFullLibrary();
    final userAddedExercises = service.loadUserLibrary();

    for (var ex in userAddedExercises) {
      if (ex.muscleGroup != null && fullMap.containsKey(ex.muscleGroup)) {
        fullMap[ex.muscleGroup]!.add(ex);
      }
    }
    _library = fullMap;
    notifyListeners();
  }

  Future<void> syncFullArchive() async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();

    _deloadTimer?.cancel();
    _archiveLogs = service.getAllLogs();

    _isSyncing = false;
    notifyListeners();

    _deloadTimer = Timer(const Duration(seconds: 60), () {
      debugPrint("[PROVIDER] Memory Tier: Archive Deloaded (60s TTL expired).");

      _archiveLogs = [];

      notifyListeners();
    });
  }

  void savePlan(WorkoutNode plan) {
    service.savePlan(plan);
    refreshAll();
  }

  void deletePlan(int id) {
    service.deletePlan(id);
    refreshAll();
  }

  void saveLog(WorkoutLog log) {
    service.saveLog(log);
    refreshAll();
  }

  void deleteLog(int id) {
    service.deleteLog(id);
    refreshAll();
  }

  void updateBodyData(String key, dynamic value) {
    _bodyData[key] = value;
    notifyListeners();
  }

  void addCustomRelic(CustomRelic relic) {
    _customRelics.add(relic);
    notifyListeners();
  }

  void setGender(bool isMale) {
    _bodyData['isMale'] = isMale;
    notifyListeners();
  }

  @override
  void dispose() {
    _deloadTimer?.cancel();
    super.dispose();
  }
}