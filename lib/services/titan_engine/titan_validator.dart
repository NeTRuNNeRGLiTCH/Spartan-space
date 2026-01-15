class TitanValidator {
  static List<String> validate(String script, List<String> existingTitles) {
    List<String> errors = [];
    String s = script.trim();
    if (s.isEmpty) return [];

    String cleanScript = s.replaceAll(RegExp(r'set\s*\(\s*this\s*\)', caseSensitive: false), "SET(THIS)");
    List<String> words = cleanScript.replaceAll("\n", " ").split(" ").map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

    final Set<String> discoveredVars = {};
    for (int i = 0; i < words.length; i++) {
      if (i > 0 && words[i - 1].toUpperCase() == "AS") {
        discoveredVars.add(words[i].toUpperCase());
      }
    }

    int temp = 0;
    List<int> stack = [];
    bool otherwiseAllowed = false;

    // Only structural words that REQUIRE a dot increment temp
    final Set<String> starters = {"WHEN", "REPEAT", "STORE", "GLOBAL", "END", "CALL"};
    final Set<String> keywords = {
      "WHEN", "DO", "OTHERWISE", "STORE", "GLOBAL", "AS", "CALL", "OF", "ALL",
      "SET", "THIS", "WEIGHT", "REPS", "SECONDS", "DISTANCE", "END", "REPEAT",
      "AND", "OR", "NOT", "SET(THIS)"
    };
    final Set<String> protocolTitles = existingTitles.map((t) => t.toUpperCase()).toSet();


    for (int i = 0; i < words.length; i++) {
      String t = words[i].toUpperCase();

      // 1. STARTERS (The "Dot Tax" payers)
      if (starters.contains(t)) {
        temp++;
        if (t == "WHEN") stack.add(1);
        if (t == "REPEAT") stack.add(0);
        // STORE, GLOBAL, END, CALL don't push to block stack (they aren't blocks)
      }

      // 2. THE SWITCHER (OTHERWISE)
      else if (t == "OTHERWISE") {
        if (!otherwiseAllowed) {
          errors.add("GRAMMAR_ERROR: 'OTHERWISE' found in illegal context.");
        }
        temp++; // Payer for the next dot
        stack.add(0); // User directive: OTHERWISE pushes 0
        otherwiseAllowed = false;
      }

      // 3. THE TERMINATOR (The "Dot Tax" collector)
      else if (t == ".") {
        temp--;

        if (stack.isNotEmpty) {
          int identity = stack.removeLast();
          // If we just popped a 1 (WHEN), we check for a bridge
          if (identity == 1 && i + 1 < words.length && words[i + 1].toUpperCase() == "OTHERWISE") {
            otherwiseAllowed = true;
          } else {
            otherwiseAllowed = false;
          }
        }
      }

      // 4. LEXER (The unknown word filter)
      bool isNumeric = double.tryParse(t) != null;
      bool isKeyword = keywords.contains(t);
      bool isOp = ["+", "-", "*", "/", "=", "=?", ">=", "<=", ">", "<", ","].contains(t);
      bool isVar = discoveredVars.contains(t) || protocolTitles.contains(t);
      bool isSpecial = t == "DO" || t == "." || (t.startsWith("SET") && int.tryParse(t.replaceAll("SET", "")) != null);

      if (!isNumeric && !isKeyword && !isOp && !isVar && !isSpecial) {
        errors.add("LEXER_ERROR: Unknown identifier '$t'.");
      }
    }

    if (temp != 0) {
      errors.add("GRAMMAR_ERROR: Protocol dot-balance failure (temp: $temp).");
    }
    if (!s.endsWith("END .")) {
      errors.add("TERMINATION_ERROR: Script must conclude with [ END . ]");
    }

    return errors;
  }
}