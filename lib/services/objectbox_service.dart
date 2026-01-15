import '../models/workout_node.dart';
import '../models/workout_log.dart';
import '../models/goal_node.dart';
import '../models/custom_protocol.dart';
import '../models/global_variable.dart';
import '../objectbox.g.dart';
import 'protocol_library_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ObjectBoxService {
  late final Store store;
  late final Box<WorkoutNode> planBox;
  late final Box<WorkoutLog> logBox;
  late final Box<GoalNode> goalBox;
  late final Box<WorkoutSet> setBox;
  late final Box<CustomProtocol> protocolBox;
  late final Box<LibraryExercise> libraryBox;
  late final Box<GlobalVariable> globalBox;

  ObjectBoxService._(this.store) {
    planBox = store.box<WorkoutNode>();
    logBox = store.box<WorkoutLog>();
    goalBox = store.box<GoalNode>();
    setBox = store.box<WorkoutSet>();
    protocolBox = store.box<CustomProtocol>();
    libraryBox = store.box<LibraryExercise>();
    globalBox = store.box<GlobalVariable>();

    _seedInitialProtocols();
  }

  static Future<ObjectBoxService> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: p.join(dir.path, "titan_obx_v3"));
    return ObjectBoxService._(store);
  }

  // NEW: Fetch only the last X days for the "Hot" tier
  List<WorkoutLog> getRecentLogs(int days) {
    final threshold = DateTime.now().subtract(Duration(days: days)).millisecondsSinceEpoch;
    final query = logBox.query(WorkoutLog_.date.greaterThan(threshold))
        .order(WorkoutLog_.date, flags: Order.descending)
        .build();
    return query.find();
  }

  double evaluateFormula(String formula, {double w = 0, int r = 0}) {
    try {
      final logic = formula.toLowerCase().replaceAll(' ', '');
      double current = logic.contains('w') ? w : r.toDouble();
      final match = RegExp(r'([+\-*/])(\d+\.?\d*)').firstMatch(logic);
      if (match == null) return current;
      String op = match.group(1)!;
      double val = double.parse(match.group(2)!);
      return op == '+' ? current + val :
      op == '-' ? current - val :
      op == '*' ? current * val :
      op == '/' ? current / val : current;
    } catch (e) {
      return w > 0 ? w : r.toDouble();
    }
  }

  void setGlobal(String name, double value) {
    final existing = globalBox.query(GlobalVariable_.name.equals(name)).build().findFirst();
    if (existing != null) {
      existing.value = value;
      globalBox.put(existing);
    } else {
      globalBox.put(GlobalVariable(name: name, value: value));
    }
  }

  double getGlobal(String name) {
    final varObject = globalBox.query(GlobalVariable_.name.equals(name)).build().findFirst();
    return varObject?.value ?? 0.0;
  }

  List<GlobalVariable> getAllGlobals() => globalBox.getAll();
  void saveProtocol(CustomProtocol protocol) => protocolBox.put(protocol);
  List<CustomProtocol> getAllProtocols() => protocolBox.getAll();

  void _seedInitialProtocols() {
    if (protocolBox.isEmpty()) {
      final templates = ProtocolLibraryService.getTemplates();
      protocolBox.putMany(templates);
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
  void saveLibraryExercise(LibraryExercise ex) => libraryBox.put(ex);
  List<LibraryExercise> loadUserLibrary() => libraryBox.getAll();
  void deleteLibraryExercise(int id) => libraryBox.remove(id);
  void deletePlan(int id) => planBox.remove(id);
  void deleteLog(int id) => logBox.remove(id);
  void deleteProtocol(int id) => protocolBox.remove(id);
}