import 'package:flutter/material.dart';
import '../models/workout_node.dart';

class LibraryMuscleCard extends StatelessWidget {
  final String muscle;
  final List<LibraryExercise> exercises;
  final VoidCallback onAdd;
  final Function(LibraryExercise) onDelete;

  const LibraryMuscleCard({
    super.key,
    required this.muscle,
    required this.exercises,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ExpansionTile(
        iconColor: Colors.orangeAccent,
        collapsedIconColor: Colors.white38,
        leading: const Icon(Icons.fitness_center, color: Colors.orangeAccent, size: 20),
        title: Text(
            muscle.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 13, color: Colors.white)
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.orangeAccent, size: 22),
          onPressed: onAdd,
        ),
        children: exercises.map((ex) => ListTile(
          dense: true,
          title: Text(
              ex.name,
              style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)
          ),
          subtitle: Text(
            _getShortLabel(ex.trackingType),
            style: const TextStyle(fontSize: 10, color: Colors.white54, letterSpacing: 1, fontWeight: FontWeight.bold),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent, size: 18),
            onPressed: () => onDelete(ex),
          ),
        )).toList(),
      ),
    );
  }

  String _getShortLabel(TrackingType type) {
    switch (type) {
      case TrackingType.weightReps: return "WEIGHT + REPS";
      case TrackingType.repsOnly: return "REPS ONLY";
      case TrackingType.time: return "TIME BASED";
      case TrackingType.distance: return "DISTANCE";
    }
  }
}