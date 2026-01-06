enum NodeType { parent, leaf }
enum ProtocolType { pyramidOverload, repRecovery, plateauBreaker, volumeKing }
enum TrackingType { weightReps, repsOnly, time, distance }

class LibraryExercise {
  final String name;
  final TrackingType trackingType;
  LibraryExercise({required this.name, required this.trackingType});
  Map<String, dynamic> toJson() => {'name': name, 'type': trackingType.index};
  factory LibraryExercise.fromJson(Map<dynamic, dynamic> json) => LibraryExercise(
    name: json['name'] ?? "Unknown",
    trackingType: TrackingType.values[json['type'] ?? 0],
  );
}

class WorkoutSet {
  int value;
  double weight;
  bool isCompleted;
  WorkoutSet({required this.value, this.weight = 0, this.isCompleted = true});
  Map<String, dynamic> toJson() => {'value': value, 'weight': weight, 'isCompleted': isCompleted};
  factory WorkoutSet.fromJson(Map<dynamic, dynamic> json) => WorkoutSet(
    value: json['value'] ?? 0,
    weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
    isCompleted: json['isCompleted'] ?? true,
  );
}

class WorkoutProtocol {
  ProtocolType type;
  int targetValue;
  double weightValue;
  int stepValue;
  double decrement;
  WorkoutProtocol({required this.type, this.targetValue = 12, this.weightValue = 5.0, this.stepValue = 5, this.decrement = 2.0});
  Map<String, dynamic> toJson() => {'type': type.index, 'targetValue': targetValue, 'weightValue': weightValue, 'stepValue': stepValue, 'decrement': decrement};
  factory WorkoutProtocol.fromJson(Map<dynamic, dynamic> json) => WorkoutProtocol(
    type: ProtocolType.values[json['type'] ?? 0],
    targetValue: json['targetValue'] ?? 12,
    weightValue: (json['weightValue'] as num?)?.toDouble() ?? 5.0,
    stepValue: json['stepValue'] ?? 5,
    decrement: (json['decrement'] as num?)?.toDouble() ?? 2.0,
  );
}

class WorkoutNode {
  String id;
  String title;
  NodeType type;
  TrackingType trackingType;
  int? restTime;
  int interExerciseRest;
  String? muscleGroup;
  List<WorkoutNode> children;
  List<WorkoutSet> sets;
  List<WorkoutProtocol> protocols;

  WorkoutNode({
    String? id,
    required this.title,
    required this.type,
    this.trackingType = TrackingType.weightReps,
    this.restTime,
    this.interExerciseRest = 180,
    this.muscleGroup,
    List<WorkoutNode>? children,
    List<WorkoutSet>? sets,
    List<WorkoutProtocol>? protocols,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        children = children ?? [],
        sets = sets ?? [],
        protocols = protocols ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type.index,
    'trackingType': trackingType.index,
    'restTime': restTime,
    'interExerciseRest': interExerciseRest,
    'muscleGroup': muscleGroup,
    'children': children.map((e) => e.toJson()).toList(),
    'sets': sets.map((e) => e.toJson()).toList(),
    'protocols': protocols.map((e) => e.toJson()).toList(),
  };

  factory WorkoutNode.fromJson(Map<dynamic, dynamic> json) => WorkoutNode(
    id: json['id'],
    title: json['title'],
    type: NodeType.values[json['type'] ?? 0],
    trackingType: TrackingType.values[json['trackingType'] ?? 0],
    restTime: json['restTime'] ?? 120,
    interExerciseRest: json['interExerciseRest'] ?? 300,
    muscleGroup: json['muscleGroup'],
    children: (json['children'] as List?)?.map((e) => WorkoutNode.fromJson(e)).toList() ?? [],
    sets: (json['sets'] as List?)?.map((e) => WorkoutSet.fromJson(e)).toList() ?? [],
    protocols: (json['protocols'] as List?)?.map((e) => WorkoutProtocol.fromJson(e)).toList() ?? [],
  );
}