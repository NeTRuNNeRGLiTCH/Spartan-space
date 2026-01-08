import '../models/workout_node.dart';
import '../models/custom_protocol.dart';
import '../objectbox.g.dart';

class TitanEngine {
  static final Map<String, double> _tempVars = {};

  // ---------------------------------------------------------------------------
  // 1. THE VALIDATOR (With Variable & Protocol Discovery)
  // ---------------------------------------------------------------------------

  static List<String> validate(String script, ProtocolScope scope, List<String> existingTitles) {
    List<String> errors = [];
    String s = script.toUpperCase().trim();

    if (s.isEmpty) return [];

    // Feature: Terminator Check
    if (!s.endsWith(".")) {
      errors.add("TERMINATION_ERROR: Logic must end with a space and a period [ . ]");
    }

    // Feature: Scope Guard
    if (scope == ProtocolScope.kinetic && s.contains("WEIGHT")) {
      errors.add("SCOPE_ERROR: 'Weight' is unauthorized in KINETIC scope.");
    }
    if (scope == ProtocolScope.chronos && (s.contains("WEIGHT") || s.contains("REPS"))) {
      errors.add("SCOPE_ERROR: Only 'Seconds' allowed in CHRONOS scope.");
    }
    if (scope == ProtocolScope.velocity && (s.contains("WEIGHT") || s.contains("REPS"))) {
      errors.add("SCOPE_ERROR: Only 'Distance' allowed in VELOCITY scope.");
    }

    // --- FEATURE: IDENTIFIER DISCOVERY ---
    // We scan the script to find variable names being declared: STORE 4 AS [NAME]
    final userDeclaredVars = <String>{};
    final asMatches = RegExp(r'AS\s+([A-Z0-9_]+)').allMatches(s);
    for (var match in asMatches) {
      if (match.group(1) != null) userDeclaredVars.add(match.group(1)!);
    }

    // Normalize existing protocol titles for comparison
    final protocolNames = existingTitles.map((t) => t.toUpperCase()).toSet();

    // --- LEXER SCAN ---
    final tokens = s.split(RegExp(r'[\s.()=+-<>*\/]+')).where((t) => t.isNotEmpty);
    final systemKeywords = {
      "WHEN", "DO", "OTHERWISE", "STORE", "AS", "CALL", "OF", "ALL",
      "SET", "THIS", "WEIGHT", "REPS", "SECONDS", "DISTANCE", "END", "REPEAT", "AND"
    };

    for (var token in tokens) {
      if (double.tryParse(token) != null) continue; // It's a number
      if (token.startsWith("SET") && token.length > 3) continue; // It's set1, set2...
      if (token == "SET(THIS)") continue;

      // VALIDATION: Word must be a System Keyword, a User Variable, or a Protocol Name
      bool isValid = systemKeywords.contains(token) ||
          userDeclaredVars.contains(token) ||
          protocolNames.contains(token);

      if (!isValid) {
        if (token == "SIT" || token == "SAT" || token == "SIT1") {
          errors.add("LEXER_ERROR: Found '$token'. Did you mean 'SET'?");
        } else {
          errors.add("LEXER_ERROR: Unknown identifier '$token'. Declare variables using STORE ... AS.");
        }
      }
    }

    return errors;
  }

  // ---------------------------------------------------------------------------
  // 2. THE EXECUTION ENGINE
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
      List<String> sentences = script.split('.').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      for (var sentence in sentences) {
        String instruction = sentence.replaceAll("___DECIMAL___", ".");

        // Feature: REPEAT Loop
        if (instruction.contains("REPEAT")) {
          final parts = instruction.split("DO");
          final countStr = parts[0].replaceAll("REPEAT", "").trim();
          final loopBody = parts[1].trim();
          int iterations = int.tryParse(countStr) ?? 1;

          for (int i = 1; i <= iterations; i++) {
            // Feature: set(this) substitution
            String iterationLogic = loopBody.replaceAll("SET(THIS)", "SET$i");
            // Feature: AND multi-action support
            List<String> subActions = iterationLogic.split("AND").map((a) => a.trim()).toList();
            for (var action in subActions) {
              results = _parseInstruction(action, results, protocol.scope, protocolBox);
            }
          }
        }
        // Feature: STORE logic
        else if (instruction.contains("STORE")) {
          _handleStorage(instruction, results, protocol.scope);
        }
        // Standard logic
        else {
          results = _parseInstruction(instruction, results, protocol.scope, protocolBox);
        }
      }
    } catch (e) {
      print("TITAN_ENGINE_FATAL: $e");
      return actualPerformance;
    }
    return results;
  }

  // ---------------------------------------------------------------------------
  // 3. INTERNAL PARSER
  // ---------------------------------------------------------------------------

  static List<WorkoutSet> _parseInstruction(String s, List<WorkoutSet> currentSets, ProtocolScope scope, Box<CustomProtocol> box) {
    // Feature: Recursive CALL
    if (s.contains("CALL")) {
      final targetName = s.split("CALL")[1].trim();
      final target = box.query(CustomProtocol_.title.equals(targetName)).build().findFirst();
      if (target != null && target.scopeIndex == scope.index) {
        return execute(protocol: target, actualPerformance: currentSets, protocolBox: box);
      }
      return currentSets;
    }

    // Feature: WHEN Conditionals
    if (s.contains("WHEN")) {
      final condPart = s.split("DO")[0].replaceAll("WHEN", "").trim();
      final actionPart = s.split("DO")[1].trim();
      final truePath = actionPart.split("OTHERWISE")[0].trim();
      final falsePath = actionPart.contains("OTHERWISE") ? actionPart.split("OTHERWISE")[1].trim() : "";

      if (_evaluateCondition(condPart, currentSets, scope)) {
        return _applyAction(truePath, currentSets, scope);
      } else if (falsePath.isNotEmpty) {
        return _applyAction(falsePath, currentSets, scope);
      }
      return currentSets;
    }

    // Feature: END return gate
    if (s.contains("END")) {
      return _applyAction(s.split("END")[1].trim(), currentSets, scope);
    }

    return _applyAction(s, currentSets, scope);
  }

  static bool _evaluateCondition(String cond, List<WorkoutSet> sets, ProtocolScope scope) {
    final ops = RegExp(r'[><=]');
    final parts = cond.split(ops);
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
    int? specificIdx;
    if (action.contains("OF SET")) {
      specificIdx = (int.tryParse(RegExp(r'\d+').stringMatch(action.split("OF SET")[1]) ?? "") ?? 1) - 1;
    }

    for (int i = 0; i < sets.length; i++) {
      if (targetAll || (specificIdx != null && specificIdx == i)) {
        String operandStr = action.split(RegExp(r'[+\-*/=]')).last.trim();
        double operand = _tempVars[operandStr] ?? (double.tryParse(RegExp(r'\d+\.?\d*').stringMatch(operandStr) ?? "0") ?? 0);

        if (action.contains("WEIGHT")) {
          if (action.contains("+")) sets[i].weight += operand;
          else if (action.contains("-")) sets[i].weight -= operand;
          else if (action.contains("*")) sets[i].weight *= operand;
          else sets[i].weight = operand;
        }
        if (action.contains("REPS") || action.contains("SECONDS") || action.contains("DISTANCE")) {
          if (action.contains("+")) sets[i].value += operand.toInt();
          else if (action.contains("-")) sets[i].value -= operand.toInt();
          else sets[i].value = operand.toInt();
        }
      }
    }
    return sets;
  }

  static void _handleStorage(String s, List<WorkoutSet> sets, ProtocolScope scope) {
    final parts = s.split("AS");
    if (parts.length < 2) return;
    _tempVars[parts[1].trim()] = _resolveValue(parts[0].replaceAll("STORE", "").trim(), sets, scope);
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