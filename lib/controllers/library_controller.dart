import '../models/workout_node.dart';
import '../providers/titan_provider.dart';

class LibraryController {
  final TitanProvider provider;

  LibraryController({required this.provider});

  void deleteExercise(LibraryExercise ex, String muscle) {
    if (ex.id != 0) {
      provider.service.deleteLibraryExercise(ex.id);
      provider.refreshAll();
    }
  }

  void addExercise(String name, TrackingType type, String muscle) {
    final newEx = LibraryExercise(
      name: name,
      trackingIndex: type.index,
      muscleGroup: muscle,
    );
    provider.service.saveLibraryExercise(newEx);
    provider.refreshAll();
  }

  String getTrackingLabel(TrackingType type) {
    return type == TrackingType.weightReps
        ? "WEIGHT + REPS (Standard)"
        : type == TrackingType.repsOnly
        ? "REPS ONLY (Calisthenics)"
        : type == TrackingType.time
        ? "TIME (Plank/Holds)"
        : "DISTANCE (Cardio)";
  }
}