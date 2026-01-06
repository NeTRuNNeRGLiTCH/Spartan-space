import 'workout_node.dart';

enum GoalNodeType { folder, exercise }

class GoalNode {
  String title;
  GoalNodeType type;
  List<GoalNode> children;

  double currentWeight;
  double targetWeight;
  double weightStep;
  int totalSessions;
  int completedSessions;

  List<WorkoutSet> sets;
  List<WorkoutProtocol> protocols;

  GoalNode({
    required this.title,
    required this.type,
    List<GoalNode>? children,
    this.currentWeight = 0,
    this.targetWeight = 0,
    this.weightStep = 2.5,
    this.totalSessions = 10,
    this.completedSessions = 0,
    List<WorkoutSet>? sets,
    List<WorkoutProtocol>? protocols,
  }) : this.children = children ?? [],
        this.sets = sets ?? [],
        this.protocols = protocols ?? [];

  double get nextTargetWeight {
    if (totalSessions <= 0 || weightStep <= 0) return currentWeight;
    double totalWeightToGain = targetWeight - currentWeight;
    int totalStepsNeeded = (totalWeightToGain / weightStep).ceil();
    int currentStep = ((totalStepsNeeded * (completedSessions + 1)) / totalSessions).floor();
    if (currentStep > totalStepsNeeded) currentStep = totalStepsNeeded;
    return currentWeight + (currentStep * weightStep);
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'type': type.index,
    'currentWeight': currentWeight,
    'targetWeight': targetWeight,
    'weightStep': weightStep,
    'totalSessions': totalSessions,
    'completedSessions': completedSessions,
    'sets': sets.map((e) => e.toJson()).toList(),
    'protocols': protocols.map((e) => e.toJson()).toList(),
    'children': children.map((e) => e.toJson()).toList(),
  };

  factory GoalNode.fromJson(Map<dynamic, dynamic> json) => GoalNode(
    title: json['title'],
    type: GoalNodeType.values[json['type'] ?? 0],
    currentWeight: (json['currentWeight'] as num?)?.toDouble() ?? 0.0,
    targetWeight: (json['targetWeight'] as num?)?.toDouble() ?? 0.0,
    weightStep: (json['weightStep'] as num?)?.toDouble() ?? 2.5,
    totalSessions: json['totalSessions'] ?? 10,
    completedSessions: json['completedSessions'] ?? 0,
    sets: (json['sets'] as List?)?.map((e) => WorkoutSet.fromJson(e)).toList() ?? [],
    protocols: (json['protocols'] as List?)?.map((e) => WorkoutProtocol.fromJson(e)).toList() ?? [],
    children: (json['children'] as List?)?.map((e) => GoalNode.fromJson(e)).toList() ?? [],
  );
}