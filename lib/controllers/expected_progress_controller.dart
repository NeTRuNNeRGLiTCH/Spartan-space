import '../models/goal_node.dart';
import '../models/workout_node.dart';
import '../providers/titan_provider.dart';

class ExpectedProgressController {
  final TitanProvider provider;

  ExpectedProgressController({
    required this.provider,
  });

  void linkRoadmapToPlan(WorkoutNode source, int totalSessions) {
    GoalNode newRoadmap = GoalNode(
      title: source.title,
      typeIndex: GoalNodeType.folder.index,
      totalSessions: totalSessions,
    );

    _cloneStructure(source, newRoadmap);

    provider.service.saveGoal(newRoadmap);
    provider.refreshAll();
  }

  void _cloneStructure(WorkoutNode source, GoalNode target) {
    for (var child in source.children.toList()) {
      if (child.type == NodeType.leaf) {
        final sets = child.sets.toList();
        double startWeight = sets.isNotEmpty ? sets.first.weight : 0;

        target.children.add(GoalNode(
          title: child.title,
          typeIndex: GoalNodeType.exercise.index,
          currentWeight: startWeight,
          targetWeight: startWeight + 10,
          weightStep: 5.0,
        ));
      } else {
        GoalNode sub = GoalNode(title: child.title, typeIndex: GoalNodeType.folder.index);
        target.children.add(sub);
        _cloneStructure(child, sub);
      }
    }
  }

  void advanceSession(GoalNode node) {
    if (node.completedSessions < node.totalSessions) {
      node.completedSessions++;
      provider.service.saveGoal(node);
      provider.refreshAll();
    }
  }

  void resetProgress(GoalNode node) {
    node.completedSessions = 0;
    provider.service.saveGoal(node);
    provider.refreshAll();
  }

  void deleteRoadmap(int id) {
    provider.service.goalBox.remove(id);
    provider.refreshAll();
  }

  void updateExerciseGoal(GoalNode node, double current, double target, double step) {
    node.currentWeight = current;
    node.targetWeight = target;
    node.weightStep = step;

    provider.service.saveGoal(node);
    provider.refreshAll();
  }
}