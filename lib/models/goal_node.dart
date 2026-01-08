import 'package:objectbox/objectbox.dart';
import 'workout_node.dart';

enum GoalNodeType { folder, exercise }

@Entity()
class GoalNode {
  @Id()
  int id = 0;

  late String title;
  int typeIndex = 0;

  double currentWeight = 0;
  double targetWeight = 0;
  double weightStep = 2.5;
  int totalSessions = 10;
  int completedSessions = 0;

  final children = ToMany<GoalNode>();
  final sets = ToMany<WorkoutSet>();

  GoalNode({
    this.id = 0,
    required this.title,
    this.typeIndex = 0,
    this.currentWeight = 0,
    this.targetWeight = 0,
    this.weightStep = 2.5,
    this.totalSessions = 10,
    this.completedSessions = 0,
  });

  @Transient()
  GoalNodeType get type => GoalNodeType.values[typeIndex];
  set type(GoalNodeType v) => typeIndex = v.index;

  double get nextTargetWeight {
    if (totalSessions <= 0 || weightStep <= 0) return currentWeight;
    double totalWeightToGain = targetWeight - currentWeight;
    int totalStepsNeeded = (totalWeightToGain / weightStep).ceil();
    int currentStep = ((totalStepsNeeded * (completedSessions + 1)) / totalSessions).floor();
    if (currentStep > totalStepsNeeded) currentStep = totalStepsNeeded;
    return currentWeight + (currentStep * weightStep);
  }
}