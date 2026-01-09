import 'package:objectbox/objectbox.dart';
import 'custom_protocol.dart';

enum NodeType { parent, leaf }
enum TrackingType { weightReps, repsOnly, time, distance }

@Entity()
class WorkoutNode {
  @Id()
  int id = 0;

  late String title;
  bool isRoot = false;

  int typeIndex = 0;
  int trackingIndex = 0;

  int? restTime;
  int interExerciseRest = 180;
  String? muscleGroup;

  final protocol = ToOne<CustomProtocol>();
  final children = ToMany<WorkoutNode>();
  final sets = ToMany<WorkoutSet>();

  // Constructor parameters now match the field names exactly
  WorkoutNode({
    this.id = 0,
    required this.title,
    this.isRoot = false,
    this.typeIndex = 0,
    this.trackingIndex = 0,
    this.restTime,
    this.interExerciseRest = 180,
    this.muscleGroup,
  });

  // UI COMPATIBILITY: These allow you to use .type and .trackingType in your logic
  @Transient()
  NodeType get type => NodeType.values[typeIndex];
  set type(NodeType v) => typeIndex = v.index;

  @Transient()
  TrackingType get trackingType => TrackingType.values[trackingIndex];
  set trackingType(TrackingType v) => trackingIndex = v.index;
}

@Entity()
class WorkoutSet {
  @Id()
  int id = 0;
  int value = 0;
  double weight = 0.0;
  bool isCompleted = false;

  WorkoutSet({
    this.id = 0,
    this.value = 0,
    this.weight = 0,
    this.isCompleted = false,
  });
}

@Entity()
class LibraryExercise {
  @Id()
  int id = 0;

  late String name;
  int trackingIndex = 0; // Field name
  String? muscleGroup;

  // Constructor parameter matches field name
  LibraryExercise({
    this.id = 0,
    required this.name,
    this.trackingIndex = 0,
    this.muscleGroup,
  });

  @Transient()
  TrackingType get trackingType => TrackingType.values[trackingIndex];
  set trackingType(TrackingType v) => trackingIndex = v.index;
}