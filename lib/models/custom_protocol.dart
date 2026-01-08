import 'package:objectbox/objectbox.dart';

enum ProtocolScope { power, kinetic, chronos, velocity }

@Entity()
class CustomProtocol {
  @Id()
  int id = 0;

  late String title;

  late String script;

  int scopeIndex = 0;

  CustomProtocol({
    this.id = 0,
    required this.title,
    required this.script,
    this.scopeIndex = 0,
  });

  @Transient()
  ProtocolScope get scope => ProtocolScope.values[scopeIndex];

  set scope(ProtocolScope value) => scopeIndex = value.index;

  @Transient()
  String get scopeLabel {
    switch (scope) {
      case ProtocolScope.power: return "POWER (Weight + Reps)";
      case ProtocolScope.kinetic: return "KINETIC (Pure Reps)";
      case ProtocolScope.chronos: return "CHRONOS (Time)";
      case ProtocolScope.velocity: return "VELOCITY (Distance)";
    }
  }
}