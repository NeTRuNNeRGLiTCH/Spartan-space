import 'package:objectbox/objectbox.dart';
import 'workout_node.dart';

@Entity()
class WorkoutLog {
  @Id()
  int id = 0;

  @Property(type: PropertyType.date)
  late DateTime date;

  late String exerciseName;
  String? muscleGroup;

  final performedSets = ToMany<WorkoutSet>();

  List<WorkoutSet> get setsList => performedSets.toList();
}