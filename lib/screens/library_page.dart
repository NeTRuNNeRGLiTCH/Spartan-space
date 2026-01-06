import 'package:flutter/material.dart';
import '../models/workout_node.dart';
import '../widgets/library_widgets.dart';

class LibraryPage extends StatefulWidget {
  final Map<String, List<LibraryExercise>> library;
  final VoidCallback onUpdate;

  const LibraryPage({super.key, required this.library, required this.onUpdate});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        title: const Text(
          "EXERCISE DATABASE",
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: widget.library.keys.map((muscle) => LibraryMuscleCard(
          muscle: muscle,
          exercises: widget.library[muscle]!,
          onAdd: () => _addNewExercise(muscle),
          onDelete: (exObject) {
            setState(() => widget.library[muscle]!.remove(exObject));
            widget.onUpdate();
          },
        )).toList(),
      ),
    );
  }

  void _addNewExercise(String muscle) {
    TextEditingController nameCtrl = TextEditingController();
    TrackingType selectedType = TrackingType.weightReps;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("ENCODE TO ${muscle.toUpperCase()}",
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 14, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Exercise Name",
                    labelStyle: TextStyle(color: Colors.white24),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orangeAccent)),
                  ),
                ),
                const SizedBox(height: 25),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("MEASUREMENT PROTOCOL:",
                      style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<TrackingType>(
                      value: selectedType,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1A1A1A),
                      icon: const Icon(Icons.expand_more, color: Colors.orangeAccent),
                      items: TrackingType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            _getTrackingLabel(type),
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() => selectedType = val!);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("ABORT", style: TextStyle(color: Colors.white24))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  setState(() {
                    widget.library[muscle]!.add(
                        LibraryExercise(name: nameCtrl.text, trackingType: selectedType)
                    );
                  });
                  widget.onUpdate();
                  Navigator.pop(ctx);
                }
              },
              child: const Text("INITIALIZE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  String _getTrackingLabel(TrackingType type) {
    switch (type) {
      case TrackingType.weightReps: return "WEIGHT + REPS (Standard)";
      case TrackingType.repsOnly: return "REPS ONLY (Calisthenics)";
      case TrackingType.time: return "TIME (Plank/Holds)";
      case TrackingType.distance: return "DISTANCE (Cardio)";
    }
  }
}