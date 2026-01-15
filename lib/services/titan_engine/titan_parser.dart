import 'titan_context.dart';
import 'handlers/base_handler.dart';
import 'handlers/store_handler.dart';
import 'handlers/global_handler.dart';
import 'handlers/when_handler.dart';
import 'handlers/repeat_handler.dart';
import 'handlers/action_handler.dart';
import 'handlers/end_handler.dart';

class TitanParser {
  static final Map<String, TitanHandler> _handlers = {
    "STORE": StoreHandler(),
    "GLOBAL": GlobalHandler(),
    "WHEN": WhenHandler(),
    "REPEAT": RepeatHandler(),
    "END": EndHandler(),
  };

  static final ActionHandler _actionHandler = ActionHandler();

  static void parse(List<List<String>> statements, TitanContext context) {

    while (statements.isNotEmpty && !context.isHalted) {
      List<String> statement = statements.removeAt(0);

      if (statement.isEmpty) continue;

      String head = statement[0].toUpperCase();

      if (head == "." || head == "OTHERWISE") {
        continue;
      }

      if (_handlers.containsKey(head)) {
        List<String> body = List<String>.from(statement)..removeAt(0);
        _handlers[head]!.handle(body, context);
      } else {
        _actionHandler.handle(List<String>.from(statement), context);
      }
    }
  }
}