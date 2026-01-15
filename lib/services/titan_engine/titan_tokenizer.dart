class TitanTokenizer {
  static List<List<String>> tokenize(String script) {

    String s = script.replaceAll(RegExp(r'set\s*\(\s*this\s*\)', caseSensitive: false), "SET(THIS)");
    s = s.replaceAll("\n", " ").replaceAll("\r", " ").trim();

    List<String> words = s.split(" ").map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    List<List<String>> statements = [];

    while (words.isNotEmpty) {
      List<String> currentStatement = [];
      List<int> blockStack = [];
      int counter = 1;
      bool firstWordChecked = false;

      while (words.isNotEmpty && counter > 0) {
        String word = words.removeAt(0);
        String upper = word.toUpperCase();
        currentStatement.add(word);

        if (!firstWordChecked) {
          if (upper == "WHEN") blockStack.add(1);
          else if (upper == "REPEAT") blockStack.add(0);
          firstWordChecked = true;
        } else {
          if (upper == "WHEN") {
            counter++;
            blockStack.add(1);
          } else if (upper == "REPEAT") {
            counter++;
            blockStack.add(0);
          } else if (upper == ".") {
            counter--;
            int identity = blockStack.isNotEmpty ? blockStack.removeLast() : -1;

            if (identity == 1 && words.isNotEmpty && words[0].toUpperCase() == "OTHERWISE") {
              currentStatement.add(words.removeAt(0));
              counter++;
              blockStack.add(0);
            }
          }
        }
      }
      if (currentStatement.isNotEmpty) statements.add(currentStatement);
    }
    return statements;
  }
}