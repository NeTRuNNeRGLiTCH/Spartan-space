import 'base_handler.dart';
import '../titan_context.dart';

class EndHandler implements TitanHandler {
  @override
  void handle(List<String> tokens, TitanContext context) {
    context.isHalted = true;
    tokens.clear();
  }
}