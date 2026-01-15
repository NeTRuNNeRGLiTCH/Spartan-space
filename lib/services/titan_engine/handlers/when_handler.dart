import 'base_handler.dart';
import '../titan_context.dart';
import '../titan_parser.dart';
import '../titan_tokenizer.dart';

class WhenHandler implements TitanHandler {
  @override
  void handle(List<String> tokens, TitanContext context) {

    int doIdx = tokens.indexWhere((t) => t.toUpperCase() == "DO");
    if (doIdx == -1) return;

    bool result = context.evaluateCondition(tokens.sublist(0, doIdx));

    int otherwiseIdx = -1;
    int depth = 1;
    final Set<String> openers = {"WHEN", "REPEAT", "OTHERWISE", "STORE", "GLOBAL", "END", "CALL"};

    for (int i = doIdx + 1; i < tokens.length; i++) {
      String t = tokens[i].toUpperCase();

      if (openers.contains(t)) {
        depth++;
      } else if (t == ".") {
        depth--;
        if (depth == 0) {
          if (i + 1 < tokens.length && tokens[i + 1].toUpperCase() == "OTHERWISE") {
            otherwiseIdx = i + 1;
            break;
          }
        }
      }
    }

    if (result) {
      List<String> body = tokens.sublist(doIdx + 1, otherwiseIdx != -1 ? otherwiseIdx : tokens.length);
      if (body.isNotEmpty && body.last == ".") body.removeLast();
      _executeRecursive(body, context);
    } else if (otherwiseIdx != -1) {
      List<String> body = tokens.sublist(otherwiseIdx + 1, tokens.length);
      if (body.isNotEmpty && body.last == ".") body.removeLast();
      _executeRecursive(body, context);
    } else {
    }
  }

  void _executeRecursive(List<String> body, TitanContext context) {
    if (body.isEmpty) return;
    String script = body.join(" ");
    TitanParser.parse(TitanTokenizer.tokenize(script), context);
  }
}