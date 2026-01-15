import '../models/custom_protocol.dart';
import '../services/titan_engine/titan_engine.dart';
import '../providers/titan_provider.dart';

class ProtocolController {
  final TitanProvider provider;

  final List<String> tokenPool = [
    "WHEN", "DO", "OTHERWISE", "STORE", "GLOBAL", "AS", "CALL", "of", "all", "AND", "OR", "NOT",
    "set(this)", "set1", "set2", "Weight", "Reps", "Seconds", "Distance",
    ".", ",", "+", "-", "*", "/", ">", "=", ">=", "<=", "=?", "END"
  ];

  List<String> activeTokens = ["WHEN", "DO", "STORE"];

  ProtocolController({
    required this.provider,
  });

  void saveProtocol(CustomProtocol? existing, String title, String script, ProtocolScope scope) {
    final p = existing ?? CustomProtocol(title: title, script: script);
    p.title = title;
    p.script = script;
    p.scope = scope;

    provider.service.saveProtocol(p);
    provider.refreshAll();
  }

  void deleteProtocol(int id) {
    provider.service.deleteProtocol(id);
    provider.refreshAll();
  }

  List<String> validate(String script, ProtocolScope scope) {
    return TitanEngine.validate(script, scope, protocolTitles);
  }

  void toggleTokenPin(String token) {
    if (activeTokens.contains(token)) {
      activeTokens.remove(token);
    } else if (activeTokens.length < 3) {
      activeTokens.add(token);
    }
    provider.refreshAll();
  }

  List<String> get protocolTitles => provider.service.getAllProtocols().map((p) => p.title).toList();
  List<CustomProtocol> get protocols => provider.service.getAllProtocols();
}