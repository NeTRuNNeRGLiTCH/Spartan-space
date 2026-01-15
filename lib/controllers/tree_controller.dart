import 'package:flutter/material.dart';
import '../models/workout_node.dart';
import '../models/goal_node.dart';
import '../models/custom_protocol.dart';
import '../providers/titan_provider.dart';

class TreeController {
  final TitanProvider provider;

  int currentIndex = 0;
  late PageController pageController;

  TreeController({
    required this.provider,
  }) {
    pageController = PageController(viewportFraction: 0.8);
    if (provider.plans.isNotEmpty) {
      currentIndex = currentIndex.clamp(0, provider.plans.length - 1);
    }
  }

  void dispose() {
    pageController.dispose();
  }

  void updateIndex(int index) {
    currentIndex = index;
    provider.refreshAll();
  }

  WorkoutNode? get activePlan => provider.plans.isNotEmpty ? provider.plans[currentIndex] : null;

  void addRootBlueprint(String title) {
    final newNode = WorkoutNode(
      title: title,
      typeIndex: NodeType.parent.index,
      isRoot: true,
      restTime: 90,
      interExerciseRest: 180,
    );
    provider.savePlan(newNode);
  }

  void updateBlueprintSpecs(WorkoutNode node, String title, int? setRest, int? interRest, bool isRoot) {
    node.title = title;
    if (isRoot) {
      node.restTime = setRest ?? 90;
      node.interExerciseRest = interRest ?? 180;
      node.isRoot = true;
    } else {
      node.restTime = null;
      node.isRoot = false;
    }
    provider.savePlan(node);
  }

  void addSubFolder(WorkoutNode parent, String title) {
    parent.children.add(WorkoutNode(
        title: title,
        typeIndex: NodeType.parent.index,
        isRoot: false
    ));
    provider.savePlan(parent);
  }

  void addExerciseToFolder(WorkoutNode parent, LibraryExercise libEx, String muscle) {
    final newNode = WorkoutNode(
      title: libEx.name,
      typeIndex: NodeType.leaf.index,
      trackingIndex: libEx.trackingType.index,
      muscleGroup: muscle,
    );
    newNode.sets.add(WorkoutSet(value: 10, weight: 0));
    parent.children.add(newNode);
    provider.savePlan(parent);
  }

  void updateLeafNode(WorkoutNode node, List<WorkoutSet> newSets, CustomProtocol? protocol, int? restTime) {
    node.sets.clear();
    node.sets.addAll(newSets);
    node.protocol.target = protocol;
    node.restTime = restTime;
    provider.savePlan(node);
  }

  void deleteNode(WorkoutNode node, WorkoutNode? parent) {
    if (parent != null) {
      parent.children.remove(node);
      provider.savePlan(parent);
    } else {
      provider.deletePlan(node.id);
    }
  }

  GoalNode? getRoadmapForPlan(WorkoutNode plan) {
    try {
      return provider.goals.firstWhere((g) => g.title == plan.title);
    } catch (e) {
      return null;
    }
  }
}