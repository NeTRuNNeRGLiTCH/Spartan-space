import '../titan_context.dart';

abstract class TitanHandler {
  void handle(List<String> tokens, TitanContext context);
}