import '../models/workout_node.dart';
import '../models/custom_protocol.dart';
import '../objectbox.g.dart';

class TitanEngine {
  static final Map<String, double> _tempVars = {};

  // ---------------------------------------------------------------------------
  // 1. THE VALIDATOR (Self-Aware & Nesting-Safe)
  // ---------------------------------------------------------------------------
  static List<String> validate(String script, ProtocolScope scope, List<String> existingTitles) {
    List<String> errors = [];
    String s = script.toUpperCase().trim();

    if (s.isEmpty) return [];

    if (!s.endsWith(".")) {
      errors.add("TERMINATION_ERROR: Logic stream must end with a period [ . ]");
    }

    // Feature: Nesting Depth Check (Counting DO vs .)
    int doCount = RegExp(r'\bDO\b').allMatches(s).length;
    int terminatorCount = RegExp(r'(?<!\d)\.(?!\d)').allMatches(s).length;
    if (doCount > terminatorCount) {
      errors.add("NESTING_ERROR: Unclosed logic gate. Missing [ . ]");
    }

    // Feature: Scope Guarding
    if (scope == ProtocolScope.kinetic && s.contains("WEIGHT")) {
      errors.add("SCOPE_ERROR: 'Weight' is unauthorized in KINETIC scope.");
    }
    if (scope == ProtocolScope.chronos && (s.contains("WEIGHT") || s.contains("REPS"))) {
      errors.add("SCOPE_ERROR: Only 'Seconds' allowed in CHRONOS scope.");
    }
    if (scope == ProtocolScope.velocity && (s.contains("WEIGHT") || s.contains("REPS"))) {
      errors.add("SCOPE_ERROR: Only 'Distance' allowed in RUNNING scope.");
    }

    final userDeclaredVars = <String>{};
    final asMatches = RegExp(r'AS\s+([A-Z0-9_]+)').allMatches(s);
    for (var match in asMatches) {
      if (match.group(1) != null) userDeclaredVars.add(match.group(1)!);
    }
    final protocolNames = existingTitles.map((t) => t.toUpperCase()).toSet();

    // Lexer Scan
    final tokens = s.split(RegExp(r'[\s()=+-<>*\/]+')).where((t) => t.isNotEmpty);
    final systemKeywords = {
      "WHEN", "DO", "OTHERWISE", "STORE", "AS", "CALL", "OF", "ALL",
      "SET", "THIS", "WEIGHT", "REPS", "SECONDS", "DISTANCE", "END", "REPEAT", "AND", "=?"
    };

    for (var token in tokens) {
      if (token == ".") continue;
      if (double.tryParse(token) != null) continue;
      if (token.startsWith("SET") && token.length > 3) continue;
      if (token == "SET(THIS)") continue;
      if (token == "=?") continue;

      bool isValid = systemKeywords.contains(token) ||
          userDeclaredVars.contains(token) ||
          protocolNames.contains(token);

      if (!isValid) {
        errors.add("LEXER_ERROR: Unknown identifier '$token'.");
      }
    }
    return errors;
  }

  // ---------------------------------------------------------------------------
  // 2. THE EXECUTION ENGINE (Recursive & Depth-Aware)
  // ---------------------------------------------------------------------------
  static List<WorkoutSet> execute({
    required CustomProtocol protocol,
    required List<WorkoutSet> actualPerformance,
    required Box<CustomProtocol> protocolBox,
  }) {
    _tempVars.clear();
    String script = protocol.script.toUpperCase();
    List<WorkoutSet> results = actualPerformance.map((s) => WorkoutSet(value: s.value, weight: s.weight)).toList();

    try {
      script = script.replaceAll(RegExp(r'(?<=\d)\.(?=\d)'), "___DECIMAL___");

      List<String> instructions = _splitIntoTopLevelInstructions(script);

      for (var instr in instructions) {
        String cleanInstr = instr.replaceAll("___DECIMAL___", ".");
        results = _processLogic(cleanInstr, results, protocol.scope, protocolBox);
      }
    } catch (e) {
      print("TITAN_ENGINE_FATAL: $e");
      return actualPerformance;
    }
    return results;
  }

  static List<String> _splitIntoTopLevelInstructions(String script) {
    List<String> parts = script.split(RegExp(r'\s+'));
    List<String> instructions = [];
    List<String> current = [];
    int depth = 0;

    for (var word in parts) {
      current.add(word);
      if (word == "DO") depth++;
      if (word == ".") {
        if (depth > 0) {
          depth--;
        } else {
          instructions.add(current.join(" "));
          current = [];
        }
      }
    }
    if (current.isNotEmpty) instructions.add(current.join(" "));
    return instructions;
  }

  static List<WorkoutSet> _processLogic(String s, List<WorkoutSet> currentSets, ProtocolScope scope, Box<CustomProtocol> box) {
    s = s.trim();
    if (s.isEmpty) return currentSets;

    if (s.startsWith("STORE")) {
      final parts = s.split("AS");
      _tempVars[parts[1].replaceAll(".", "").trim()] = _resolveValue(parts[0].replaceAll("STORE", "").trim(), currentSets, scope);
      return currentSets;
    }

    if (s.contains("REPEAT")) {
      final loopParts = s.split("DO");
      final countPart = loopParts[0].replaceAll("REPEAT", "").trim();
      final bodyPart = s.substring(s.indexOf("DO") + 2, s.lastIndexOf(".")).trim();

      int iterations = int.tryParse(countPart) ?? 1;
      for (int i = 1; i <= iterations; i++) {
        String iterationLogic = bodyPart.replaceAll("SET(THIS)", "SET$i");
        List<String> actions = iterationLogic.split("AND").map((a) => a.trim()).toList();
        for (var action in actions) {
          currentSets = _processLogic(action, currentSets, scope, box);
        }
      }
      return currentSets;
    }

    if (s.startsWith("WHEN")) {
      final condPart = s.split("DO")[0].replaceAll("WHEN", "").trim();
      final bodyPart = s.substring(s.indexOf("DO") + 2, s.lastIndexOf(".")).trim();
      final truePath = bodyPart.split("OTHERWISE")[0].trim();
      final falsePath = bodyPart.contains("OTHERWISE") ? bodyPart.split("OTHERWISE")[1].trim() : "";

      if (_evaluateCondition(condPart, currentSets, scope)) {
        return _processLogic(truePath, currentSets, scope, box);
      } else if (falsePath.isNotEmpty) {
        return _processLogic(falsePath, currentSets, scope, box);
      }
      return currentSets;
    }

    if (s.contains("CALL")) {
      final target = box.query(CustomProtocol_.title.equals(s.split("CALL")[1].replaceAll(".", "").trim())).build().findFirst();
      return (target != null && target.scopeIndex == scope.index) ? execute(protocol: target, actualPerformance: currentSets, protocolBox: box) : currentSets;
    }

    return _applyAction(s, currentSets, scope);
  }

  static bool _evaluateCondition(String cond, List<WorkoutSet> sets, ProtocolScope scope) {
    final ops = RegExp(r'[><=]+');
    final parts = cond.split(ops);
    double leftVal = _resolveValue(parts[0], sets, scope);
    String rightSide = parts.last.trim();
    double rightVal = _tempVars[rightSide] ?? (double.tryParse(RegExp(r'\d+\.?\d*').stringMatch(rightSide) ?? "0") ?? 0);

    if (cond.contains(">=")) return leftVal >= rightVal;
    if (cond.contains("<=")) return leftVal <= rightVal;
    if (cond.contains(">")) return leftVal > rightVal;
    if (cond.contains("<")) return leftVal < rightVal;
    if (cond.contains("=?") || cond.contains("=")) return leftVal == rightVal;
    return false;
  }

  static List<WorkoutSet> _applyAction(String action, List<WorkoutSet> sets, ProtocolScope scope) {
    String operandStr = action.split(RegExp(r'[+\-*/=]')).last.trim();
    double operand = _tempVars[operandStr] ?? (double.tryParse(RegExp(r'\d+\.?\d*').stringMatch(operandStr) ?? "0") ?? 0);

    if (!action.contains("WEIGHT") && !action.contains("REPS") && !action.contains("SECONDS") && !action.contains("DISTANCE")) {
      final varName = action.split(RegExp(r'[+\-*/=]'))[0].trim();
      if (_tempVars.containsKey(varName)) {
        if (action.contains("+")) _tempVars[varName] = _tempVars[varName]! + operand;
        else if (action.contains("-")) _tempVars[varName] = _tempVars[varName]! - operand;
        else if (action.contains("*")) _tempVars[varName] = _tempVars[varName]! * operand;
        else _tempVars[varName] = operand;
      }
      return sets;
    }

    bool targetAll = action.contains("OF ALL") || (!action.contains("OF SET"));
    int? specificIdx;
    if (action.contains("OF SET")) {
      specificIdx = (int.tryParse(RegExp(r'\d+').stringMatch(action.split("OF SET")[1]) ?? "") ?? 1) - 1;
    }

    for (int i = 0; i < sets.length; i++) {
      if (targetAll || (specificIdx != null && specificIdx == i)) {
        if (action.contains("WEIGHT")) {
          if (action.contains("+")) sets[i].weight += operand;
          else if (action.contains("-")) sets[i].weight -= operand;
          else if (action.contains("*")) sets[i].weight *= operand;
          else sets[i].weight = operand;
        } else {
          if (action.contains("+")) sets[i].value += operand.toInt();
          else if (action.contains("-")) sets[i].value -= operand.toInt();
          else sets[i].value = operand.toInt();
        }
      }
    }
    return sets;
  }

  static double _resolveValue(String part, List<WorkoutSet> sets, ProtocolScope scope) {
    String p = part.trim();
    if (_tempVars.containsKey(p)) return _tempVars[p]!;
    int idx = 0;
    if (p.contains("SET")) idx = (int.tryParse(RegExp(r'\d+').stringMatch(p.split("SET")[1]) ?? "") ?? 1) - 1;
    if (idx < 0 || idx >= sets.length) idx = 0;
    if (p.contains("WEIGHT")) return sets[idx].weight;
    if (p.contains("REPS") || p.contains("SECONDS") || p.contains("DISTANCE")) return sets[idx].value.toDouble();
    return double.tryParse(RegExp(r'\d+\.?\d*').stringMatch(p) ?? "0") ?? 0;
  }
}