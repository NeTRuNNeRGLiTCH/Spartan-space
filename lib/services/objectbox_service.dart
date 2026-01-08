import '../models/workout_node.dart';
import '../models/workout_log.dart';
import '../models/goal_node.dart';
import '../models/custom_protocol.dart';
import '../objectbox.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ObjectBoxService {
  late final Store store;
  late final Box<WorkoutNode> planBox;
  late final Box<WorkoutLog> logBox;
  late final Box<GoalNode> goalBox;
  late final Box<WorkoutSet> setBox;
  late final Box<CustomProtocol> protocolBox;

  ObjectBoxService._(this.store) {
    planBox = store.box<WorkoutNode>();
    logBox = store.box<WorkoutLog>();
    goalBox = store.box<GoalNode>();
    setBox = store.box<WorkoutSet>();
    protocolBox = store.box<CustomProtocol>();

    _seedInitialProtocols();
  }

  static Future<ObjectBoxService> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: p.join(dir.path, "titan_obx_v3"));
    return ObjectBoxService._(store);
  }


  void saveProtocol(CustomProtocol protocol) => protocolBox.put(protocol);

  List<CustomProtocol> getAllProtocols() => protocolBox.getAll();

  void _seedInitialProtocols() {
    if (protocolBox.isEmpty()) {
      protocolBox.put(CustomProtocol(
        title: "LINEAR OVERLOAD V1",
        script: """
                STORE Weight of set1 AS current_load . 
                WHEN Reps of set1 >= 12 DO Weight of all + 2.5 OTHERWISE Weight of all = current_load . 
                """,
      ));
    }
  }


  void savePlan(WorkoutNode plan) => planBox.put(plan);

  List<WorkoutNode> loadPlans() {
    final query = planBox.query(
        WorkoutNode_.typeIndex.equals(NodeType.parent.index)
            .and(WorkoutNode_.isRoot.equals(true))
    ).build();
    return query.find();
  }


  List<WorkoutLog> getLogsForDay(DateTime date) {
    final start = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59).millisecondsSinceEpoch;
    final query = logBox.query(WorkoutLog_.date.between(start, end)).build();
    return query.find();
  }

  List<WorkoutLog> getAllLogs() {
    final query = logBox.query().order(WorkoutLog_.date, flags: Order.descending).build();
    return query.find();
  }

  void saveLog(WorkoutLog log) => logBox.put(log);


  void saveGoal(GoalNode goal) => goalBox.put(goal);
  List<GoalNode> loadGoals() => goalBox.getAll();


  void deletePlan(int id) => planBox.remove(id);
  void deleteLog(int id) => logBox.remove(id);
  void deleteProtocol(int id) => protocolBox.remove(id);
}