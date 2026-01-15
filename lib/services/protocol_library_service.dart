import '../models/custom_protocol.dart';

class ProtocolLibraryService {
  static List<CustomProtocol> getTemplates() {
    return [
      CustomProtocol(
        title: "LINEAR OVERLOAD V1",
        scopeIndex: ProtocolScope.power.index,
        script: "WHEN Reps of all >= 12 DO Weight of all + 2.5 . OTHERWISE Weight of all . END .",
      ),
      CustomProtocol(
        title: "POWER PYRAMID",
        scopeIndex: ProtocolScope.power.index,
        script: "REPEAT 4 DO Weight of set(this) + 5 , Reps of set(this) - 2 . END .",
      ),
      CustomProtocol(
        title: "STRENGTH PEAKING",
        scopeIndex: ProtocolScope.power.index,
        script: "WHEN Reps of all >= 5 DO Weight of all + 5 . OTHERWISE Weight of all . END .",
      ),
      CustomProtocol(
        title: "HYPERTROPHY PUMP",
        scopeIndex: ProtocolScope.power.index,
        script: "WHEN Reps of set1 >= 15 DO Weight of all + 1.25 . OTHERWISE Weight of all . END .",
      ),
      CustomProtocol(
        title: "VOLUME MASTER",
        scopeIndex: ProtocolScope.kinetic.index,
        script: "WHEN Reps of all >= 20 DO Reps of all + 2 . END .",
      ),
      CustomProtocol(
        title: "EXPLOSIVE STEP",
        scopeIndex: ProtocolScope.kinetic.index,
        script: "WHEN Reps of all >= 10 DO Reps of all + 1 . END .",
      ),
      CustomProtocol(
        title: "ENDURANCE PUSH",
        scopeIndex: ProtocolScope.chronos.index,
        script: "WHEN Seconds of all >= 60 DO Seconds of all + 10 . END .",
      ),
      CustomProtocol(
        title: "NEURAL ADAPTATION",
        scopeIndex: ProtocolScope.chronos.index,
        script: "WHEN Seconds of all >= 120 DO Seconds of all + 15 . END .",
      ),
      CustomProtocol(
        title: "DISTANCE CLIMBER",
        scopeIndex: ProtocolScope.velocity.index,
        script: "WHEN Distance of all >= 5000 DO Distance of all + 500 . END .",
      ),
      CustomProtocol(
        title: "SPRINT INCREMENT",
        scopeIndex: ProtocolScope.velocity.index,
        script: "WHEN Distance of all >= 1000 DO Distance of all + 100 . END .",
      ),
    ];
  }

  static List<CustomProtocol> getTemplatesByScope(ProtocolScope scope) {
    return getTemplates().where((t) => t.scopeIndex == scope.index).toList();
  }

  static String getTemplateDescription(String title) {
    switch (title) {
      case "LINEAR OVERLOAD V1":
        return "Classic progression. If all sets hit 12 reps, weight increases by 2.5kg. Uses v2.1.0 dual-dot branch logic.";
      case "POWER PYRAMID":
        return "Builds a 4-set pyramid: weight increases while reps decrease automatically in one loop.";
      case "VOLUME MASTER":
        return "Ideal for bodyweight exercises. Increases target volume once 20 reps are achieved.";
      case "ENDURANCE PUSH":
        return "Timed holds. Once you hit 60 seconds on all sets, the target moves to 70.";
      case "DISTANCE CLIMBER":
        return "Cardio progression. Adds 500m to your goal once the performance target is reached.";
      default:
        return "Standard Titan optimization protocol.";
    }
  }
}