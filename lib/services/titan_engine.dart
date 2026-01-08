import '../models/workout_node.dart';
import '../models/custom_protocol.dart';
import '../objectbox.g.dart';

/// TITAN_ENGINE_OS V1.0
/// High-Performance Biometric Logic Interpreter
class TitanEngine {
  static final Map<String, double> _tempVars = {};

  // ---------------------------------------------------------------------------
  // 1. THE COMPILER
  // ---------------------------------------------------------------------------

  /// Scans the script for syntax errors, typos, and scope violations.
  /// Returns a list of readable error strings.
  static List<String> validate(String script, ProtocolScope scope) {
    List<String> errors = [];
    String s = script.toUpperCase().trim();

    if (s.isEmpty) return [];

    // RULE: Every logic stream must end with a period.
    if (!s.endsWith(".")) {
      errors.add("TERMINATION_ERROR: Logic stream must end with a space and a period [ . ]");
    }

    // RULE: Decimal protection - ensures user didn't write "5." instead of "5 . "
    final decimalCheck = RegExp(r'\d\.$');
    if (decimalCheck.hasMatch(s)) {
      errors.add("SYNTAX_ERROR: Ambiguous terminator. Ensure a space exists between numbers and the period.");
    }

    // RULE: Scope-Locking Variables
    if (scope == ProtocolScope.kinetic && s.contains("WEIGHT")) {
      errors.add("SCOPE_ERROR: 'Weight' is unauthorized in CALISTHENICS scope.");
    }
    if (scope == ProtocolScope.chronos && (s.contains("WEIGHT") || s.contains("REPS"))) {
      errors.add("SCOPE_ERROR: Only 'Seconds' allowed in PLANK/HOLDS scope.");
    }
    if (scope == ProtocolScope.velocity && (s.contains("WEIGHT") || s.contains("REPS"))) {
      errors.add("SCOPE_ERROR: Only 'Distance' allowed in RUNNING/VELOCITY scope.");
    }

    // RULE: Lexer Typo Detection
    final tokens = s.split(RegExp(r'[\s.()=+-<>*\/]+')).where((t) => t.isNotEmpty);
    final validKeywords = {
      "WHEN", "DO", "OTHERWISE", "STORE", "AS", "CALL", "OF", "ALL",
      "SET", "THIS", "WEIGHT", "REPS", "SECONDS", "DISTANCE", "END", "REPEAT", "AND"
    };

    for (var token in tokens) {
      if (double.tryParse(token) != null) continue;
      if (token.startsWith("SET") && token.length > 3) continue;
      if (token == "SET(THIS)") continue;

      if (!validKeywords.contains(token) && !_tempVars.containsKey(token)) {
        if (token == "SIT" || token == "SAT" || token == "SIT1") {
          errors.add("LEXER_ERROR: Found '$token'. Did you mean 'SET'?");
        } else if (token == "WIEGHT" || token == "WIGHT") {
          errors.add("LEXER_ERROR: Found '$token'. Did you mean 'WEIGHT'?");
        } else {
          errors.add("LEXER_ERROR: Unknown identifier '$token'. check Codex for valid variables.");
        }
      }
    }

    return errors;
  }

  // ---------------------------------------------------------------------------
  // 2. THE EXECUTION ENGINE
  // ---------------------------------------------------------------------------

  /// Interprets the TitanScript and returns a modified list of WorkoutSets.
  static List<WorkoutSet> execute({
    required CustomProtocol protocol,
    required List<WorkoutSet> actualPerformance,
    required Box<CustomProtocol> protocolBox,
  }) {
    _tempVars.clear();
    String script = protocol.script.toUpperCase();

    List<WorkoutSet> results = actualPerformance.map((s) =>
        WorkoutSet(value: s.value, weight: s.weight)).toList();

    try {
      script = script.replaceAll(RegExp(r'(?<=\d)\.(?=\d)'), "___PROTECTED_DECIMAL___");

      List<String> sentences = script.split('.').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      for (var sentence in sentences) {
        String instruction = sentence.replaceAll("___PROTECTED_DECIMAL___", ".");

        // --- PHASE: REPEAT LOOP ---
        if (instruction.contains("REPEAT")) {
          final loopHeader = instruction.split("DO")[0].replaceAll("REPEAT", "").trim();
          final loopBody = instruction.split("DO")[1].trim();
          int iterations = int.tryParse(loopHeader) ?? 1;

          for (int i = 1; i <= iterations; i++) {
            String iterativeLogic = loopBody.replaceAll("SET(THIS)", "SET$i");

            List<String> actions = iterativeLogic.split("AND").map((a) => a.trim()).toList();
            for (var action in actions) {
              results = _parseInstruction(action, results, protocol.scope, protocolBox);
            }
          }
        }
        // --- PHASE: STORE DATA ---
        else if (instruction.contains("STORE")) {
          _handleStorage(instruction, results, protocol.scope);
        }
        // --- PHASE: STANDARD INSTRUCTION ---
        else {
          results = _parseInstruction(instruction, results, protocol.scope, protocolBox);
        }
      }
    } catch (e) {
      print("TITAN_ENGINE_TERMINATED_ABNORMALLY: $e");
      return actualPerformance;
    }
    return results;
  }

  // ---------------------------------------------------------------------------
  // 3. INTERNAL PARSER LOGIC
  // ---------------------------------------------------------------------------

  static List<WorkoutSet> _parseInstruction(String s, List<WorkoutSet> currentSets, ProtocolScope scope, Box<CustomProtocol> box) {
    // RECURSION: Function Inter-Calling
    if (s.contains("CALL")) {
      final targetName = s.split("CALL")[1].trim();
      final target = box.query(CustomProtocol_.title.equals(targetName)).build().findFirst();
      if (target != null && target.scopeIndex == scope.index) {
        return execute(protocol: target, actualPerformance: currentSets, protocolBox: box);
      }
      return currentSets;
    }

    // CONDITIONALS: WHEN ... DO ... OTHERWISE
    if (s.contains("WHEN")) {
      final condition = s.split("DO")[0].replaceAll("WHEN", "").trim();
      final actionPart = s.split("DO")[1].trim();
      final truePath = actionPart.split("OTHERWISE")[0].trim();
      final falsePath = actionPart.contains("OTHERWISE") ? actionPart.split("OTHERWISE")[1].trim() : "";

      if (_evaluateCondition(condition, currentSets, scope)) {
        return _applyAction(truePath, currentSets, scope);
      } else if (falsePath.isNotEmpty) {
        return _applyAction(falsePath, currentSets, scope);
      }
      return currentSets;
    }

    // RETURN GATES: END
    if (s.contains("END")) {
      final val = s.split("END")[1].trim();
      return _applyAction(val, currentSets, scope);
    }

    // DIRECT ASSIGNMENT
    return _applyAction(s, currentSets, scope);
  }

  static bool _evaluateCondition(String cond, List<WorkoutSet> sets, ProtocolScope scope) {
    final operators = RegExp(r'[><=]');
    final parts = cond.split(operators);
    double leftVal = _resolveValue(parts[0], sets, scope);

    String rightSide = parts.last.trim();
    double rightVal = _tempVars[rightSide] ?? (double.tryParse(RegExp(r'\d+\.?\d*').stringMatch(rightSide) ?? "0") ?? 0);

    if (cond.contains(">=")) return leftVal >= rightVal;
    if (cond.contains("<=")) return leftVal <= rightVal;
    if (cond.contains(">")) return leftVal > rightVal;
    if (cond.contains("<")) return leftVal < rightVal;
    if (cond.contains("=")) return leftVal == rightVal;
    return false;
  }

  static List<WorkoutSet> _applyAction(String action, List<WorkoutSet> sets, ProtocolScope scope) {
    bool targetAll = action.contains("OF ALL") || (!action.contains("OF SET"));
    int? specificSetIdx;
    if (action.contains("OF SET")) {
      specificSetIdx = (int.tryParse(RegExp(r'\d+').stringMatch(action.split("OF SET")[1]) ?? "") ?? 1) - 1;
    }

    for (int i = 0; i < sets.length; i++) {
      if (targetAll || (specificSetIdx != null && specificSetIdx == i)) {
        String deltaStr = action.split(RegExp(r'[+\-*/=]')).last.trim();
        double delta = _tempVars[deltaStr] ?? (double.tryParse(RegExp(r'\d+\.?\d*').stringMatch(deltaStr) ?? "0") ?? 0);

        if (action.contains("WEIGHT")) {
          if (action.contains("+")) sets[i].weight += delta;
          else if (action.contains("-")) sets[i].weight -= delta;
          else if (action.contains("*")) sets[i].weight *= delta;
          else if (action.contains("/")) sets[i].weight /= delta;
          else sets[i].weight = delta;
        }
        else if (action.contains("REPS") || action.contains("SECONDS") || action.contains("DISTANCE")) {
          double current = sets[i].value.toDouble();
          if (action.contains("+")) sets[i].value = (current + delta).toInt();
          else if (action.contains("-")) sets[i].value = (current - delta).toInt();
          else sets[i].value = delta.toInt();
        }
      }
    }
    return sets;
  }

  static void _handleStorage(String s, List<WorkoutSet> sets, ProtocolScope scope) {
    final parts = s.split("AS");
    if (parts.length < 2) return;

    final dataKey = parts[0].replaceAll("STORE", "").trim();
    final varName = parts[1].trim();
    _tempVars[varName] = _resolveValue(dataKey, sets, scope);
  }

  static double _resolveValue(String part, List<WorkoutSet> sets, ProtocolScope scope) {
    if (_tempVars.containsKey(part.trim())) return _tempVars[part.trim()]!;

    int idx = 0;
    if (part.contains("SET")) {
      idx = (int.tryParse(RegExp(r'\d+').stringMatch(part.split("SET")[1]) ?? "") ?? 1) - 1;
    }
    if (idx < 0 || idx >= sets.length) idx = 0;

    if (part.contains("WEIGHT")) return sets[idx].weight;
    if (part.contains("REPS") || part.contains("SECONDS") || part.contains("DISTANCE")) return sets[idx].value.toDouble();

    return double.tryParse(RegExp(r'\d+\.?\d*').stringMatch(part) ?? "0") ?? 0;
  }
}