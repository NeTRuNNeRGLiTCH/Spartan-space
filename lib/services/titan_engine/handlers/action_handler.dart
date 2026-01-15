import 'base_handler.dart';
import '../titan_context.dart';

class ActionHandler implements TitanHandler {
  final Set<String> reserved = {
    "WHEN", "DO", "OTHERWISE", "STORE", "GLOBAL", "AS", "CALL", "OF", "ALL",
    "END", "REPEAT", "AND", "OR", "NOT"
  };

  @override
  void handle(List<String> tokens, TitanContext context) {

    while (tokens.isNotEmpty) {
      String rawHead = tokens[0].toUpperCase();

      if (rawHead == "," || rawHead == ".") {
        tokens.removeAt(0);
        continue;
      }

      String identifier = tokens.removeAt(0).toUpperCase();

      if (reserved.contains(identifier)) {
        continue;
      }

      int? targetIdx;
      bool isBio = ["WEIGHT", "REPS", "SECONDS", "DISTANCE"].contains(identifier);

      if (isBio && tokens.isNotEmpty && tokens[0].toUpperCase() == "OF") {
        tokens.removeAt(0);
        String ptr = tokens.removeAt(0).toUpperCase();
        if (ptr != "ALL") {
          targetIdx = ptr == "SET(THIS)"
              ? (context.loopIndex ?? 0)
              : (int.tryParse(ptr.replaceAll(RegExp(r'[^0-9]'), "")) ?? 1) - 1;
        }
      }

      if (tokens.isEmpty || tokens[0] == "." || tokens[0] == ",") {
        continue;
      }

      String op = tokens.removeAt(0);
      double val = context.resolveValue(tokens.removeAt(0));

      if (isBio) {
        for (int j = 0; j < context.sets.length; j++) {
          if (targetIdx == null || targetIdx == j) {
            bool isW = identifier == "WEIGHT";
            double base = isW ? context.sets[j].weight : context.sets[j].value.toDouble();
            double res = _calc(base, op, val);
            isW ? context.sets[j].weight = res : context.sets[j].value = res.toInt();
          }
        }
      } else {
        double base = context.localVars[identifier] ?? context.service.getGlobal(identifier);
        double res = _calc(base, op, val);
        context.localMemory(identifier, res);
      }

      if (tokens.isNotEmpty && (tokens[0] == "," || tokens[0] == ".")) {
        tokens.removeAt(0);
        if (tokens.isEmpty || tokens[0] == ".") return;
      }
    }
  }

  double _calc(double a, String op, double b) {
    switch (op) {
      case "+": return a + b;
      case "-": return a - b;
      case "*": return a * b;
      case "/": return a / b;
      case "=": return b;
      default: return a;
    }
  }
}

extension MemorySync on TitanContext {
  void localMemory(String key, double value) {
    localVars[key] = value;
    if (hasGlobal(key)) {
      service.setGlobal(key, value);
    }
  }
}