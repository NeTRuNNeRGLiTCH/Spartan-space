import '../../models/workout_node.dart';
import '../../models/custom_protocol.dart';
import '../objectbox_service.dart';
import 'titan_tokenizer.dart';
import 'titan_context.dart';
import 'titan_parser.dart';
import 'titan_validator.dart';

class TitanEngine {
  static List<String> validate(String script, ProtocolScope scope, List<String> existingTitles) {
    return TitanValidator.validate(script, existingTitles);
  }

  static List<WorkoutSet> execute({
    required CustomProtocol protocol,
    required List<WorkoutSet> actualPerformance,
    required ObjectBoxService service,
  }) {

    final statements = TitanTokenizer.tokenize(protocol.script);

    List<WorkoutSet> results = actualPerformance.map((s) => WorkoutSet(
        value: s.value,
        weight: s.weight,
        isCompleted: s.isCompleted
    )).toList();

    final context = TitanContext(
      service: service,
      sets: results,
    );

    try {
      TitanParser.parse(statements, context);
    } catch (e) {
      return actualPerformance;
    }

    return results;
  }
}