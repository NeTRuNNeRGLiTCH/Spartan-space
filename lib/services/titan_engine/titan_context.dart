import '../../models/workout_node.dart';
import '../../objectbox.g.dart';
import '../objectbox_service.dart';

class TitanContext {
  final ObjectBoxService service;
  final List<WorkoutSet> sets;
  final Map<String, double> localVars = {};
  bool isHalted = false;
  int? loopIndex;

  TitanContext({
    required this.service,
    required this.sets,
    this.loopIndex,
  });

  bool hasGlobal(String name) {
    return service.globalBox
        .query(GlobalVariable_.name.equals(name.toUpperCase()))
        .build()
        .findFirst() != null;
  }

  void setLocalMemory(String key, double value) {
    String k = key.toUpperCase();
    localVars[k] = value;
    if (hasGlobal(k)) {
      service.setGlobal(k, value);
    }
  }

  double resolveValue(String token) {
    String t = token.toUpperCase();

    if (double.tryParse(t) != null) {
      return double.parse(t);
    }

    if (localVars.containsKey(t)) {
      return localVars[t]!;
    }

    if (hasGlobal(t)) {
      return service.getGlobal(t);
    }

    int idx = loopIndex ?? 0;
    if (idx >= 0 && idx < sets.length) {
      if (t == "WEIGHT") return sets[idx].weight;
      if (t == "REPS" || t == "SECONDS" || t == "DISTANCE") return sets[idx].value.toDouble();
    }

    return 0;
  }

  double resolvePhrase(List<String> phrase) {
    if (phrase.isEmpty) return 0;
    if (phrase.length == 1) return resolveValue(phrase[0]);

    String metric = phrase[0].toUpperCase();
    if (phrase.length >= 3 && phrase[1].toUpperCase() == "OF") {
      String target = phrase[2].toUpperCase();

      if (target == "ALL") {
        if (sets.isEmpty) return 0;
        double minValue = 999999;
        for (var s in sets) {
          double val = metric == "WEIGHT" ? s.weight : s.value.toDouble();
          if (val < minValue) minValue = val;
        }
        return minValue == 999999 ? 0 : minValue;
      }

      int index = target == "SET(THIS)"
          ? (loopIndex ?? 0)
          : (int.tryParse(target.replaceAll(RegExp(r'[^0-9]'), "")) ?? 1) - 1;

      if (index >= 0 && index < sets.length) {
        return metric == "WEIGHT" ? sets[index].weight : sets[index].value.toDouble();
      }
    }

    return resolveValue(phrase[0]);
  }

  bool evaluateCondition(List<String> tokens) {
    if (tokens.isEmpty) return false;

    int andIdx = tokens.indexWhere((t) => t.toLowerCase() == "and");
    if (andIdx != -1) {
      return evaluateCondition(tokens.sublist(0, andIdx)) &&
          evaluateCondition(tokens.sublist(andIdx + 1));
    }

    int orIdx = tokens.indexWhere((t) => t.toLowerCase() == "or");
    if (orIdx != -1) {
      return evaluateCondition(tokens.sublist(0, orIdx)) ||
          evaluateCondition(tokens.sublist(orIdx + 1));
    }

    if (tokens[0].toLowerCase() == "not") {
      return !evaluateCondition(tokens.sublist(1));
    }

    int opIdx = -1;
    String? foundOp;
    for (int i = 0; i < tokens.length; i++) {
      String t = tokens[i].trim();
      if (t == ">=" || t == "<=" || t == "=?" || t == ">" || t == "<") {
        opIdx = i;
        foundOp = t;
        break;
      }
    }

    if (opIdx == -1) return false;

    double leftVal = resolvePhrase(tokens.sublist(0, opIdx));
    double rightVal = resolvePhrase(tokens.sublist(opIdx + 1));

    switch (foundOp) {
      case "=?": return leftVal == rightVal;
      case ">=": return leftVal >= rightVal;
      case "<=": return leftVal <= rightVal;
      case ">": return leftVal > rightVal;
      case "<": return leftVal < rightVal;
      default: return false;
    }
  }
}