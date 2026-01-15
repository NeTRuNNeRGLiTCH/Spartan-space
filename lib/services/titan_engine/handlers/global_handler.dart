import 'base_handler.dart';
import '../titan_context.dart';

class GlobalHandler implements TitanHandler {
  @override
  void handle(List<String> tokens, TitanContext context) {
    if (tokens.length < 3) {
      return;
    }

    double val = context.resolveValue(tokens.removeAt(0));
    tokens.removeAt(0);
    String name = tokens.removeAt(0).toUpperCase();

    context.service.setGlobal(name, val);
  }
}