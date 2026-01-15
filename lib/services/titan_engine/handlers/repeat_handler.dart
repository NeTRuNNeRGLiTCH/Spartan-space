import 'base_handler.dart';
import '../titan_context.dart';
import '../titan_parser.dart';
import '../titan_tokenizer.dart';

class RepeatHandler implements TitanHandler {
  @override
  void handle(List<String> tokens, TitanContext context) {
    if (tokens.isEmpty) return;
    double countVal = context.resolveValue(tokens.removeAt(0));
    int count = countVal.toInt();

    int doIdx = tokens.indexWhere((t) => t.toUpperCase() == "DO");
    if (doIdx == -1) return;

    int terminalDotIdx = tokens.length - 1;
    int depth = 1;
    final Set<String> openers = {"WHEN", "REPEAT", "OTHERWISE", "STORE", "GLOBAL", "END", "CALL"};

    for (int i = doIdx + 1; i < tokens.length; i++) {
      String t = tokens[i].toUpperCase();
      if (openers.contains(t)) {
        depth++;
      } else if (t == ".") {
        depth--;
        if (depth == 0) {
          terminalDotIdx = i;
          break;
        }
      }
    }

    List<String> body = tokens.sublist(doIdx + 1, terminalDotIdx);
    String script = body.join(" ");

    var subStatements = TitanTokenizer.tokenize(script);
    int? originalIndex = context.loopIndex;

    for (int i = 0; i < count; i++) {
      if (context.isHalted) break;
      context.loopIndex = i;
      var cycleStatements = subStatements.map((s) => List<String>.from(s)).toList();
      TitanParser.parse(cycleStatements, context);
    }
    context.loopIndex = originalIndex;
  }
}