import 'package:flutter/material.dart';
import '../models/workout_node.dart';
import '../models/custom_protocol.dart';
import '../providers/titan_provider.dart';

class WorkoutRoutineController {
  final TitanProvider provider;
  final WorkoutNode plan;
  final WorkoutNode? selectedDay;

  List<WorkoutNode> exercises = [];
  final TextEditingController objectiveController = TextEditingController();

  WorkoutRoutineController({
    required this.provider,
    required this.plan,
    this.selectedDay,
  }) {
    initializeSession();
  }

  void initializeSession() {
    exercises.clear();
    selectedDay != null ? _flatten(selectedDay!, exercises) : _flatten(plan, exercises);
  }

  void _flatten(WorkoutNode node, List<WorkoutNode> list) {
    if (node.type == NodeType.leaf) {
      list.add(node);
    } else {
      for (var child in node.children.toList()) {
        _flatten(child, list);
      }
    }
  }

  void attachProtocol(WorkoutNode ex, CustomProtocol? protocol) {
    ex.protocol.target = protocol;
    provider.savePlan(ex);
  }

  void clearProtocol(WorkoutNode ex) {
    ex.protocol.target = null;
    provider.savePlan(ex);
  }

  void updateSetTarget(WorkoutSet set, String val, bool isWeight) {
    isWeight
        ? set.weight = double.tryParse(val) ?? 0
        : set.value = int.tryParse(val) ?? 0;
    provider.refreshAll();
  }
}