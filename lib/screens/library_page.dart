import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_node.dart';
import '../widgets/library_widgets.dart';
import '../providers/titan_provider.dart';
import '../controllers/library_controller.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late LibraryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LibraryController(
      provider: context.read<TitanProvider>(),
    );
  }

  void _addNewExercise(String muscle) {
    final nameCtrl = TextEditingController();
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
                            _controller.getTrackingLabel(type),
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
                  _controller.addExercise(nameCtrl.text, selectedType, muscle);
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

  @override
  Widget build(BuildContext context) {
    final library = context.watch<TitanProvider>().library;

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
        children: library.keys.map((muscle) => LibraryMuscleCard(
          muscle: muscle,
          exercises: library[muscle]!,
          onAdd: () => _addNewExercise(muscle),
          onDelete: (exObject) => _controller.deleteExercise(exObject, muscle),
        )).toList(),
      ),
    );
  }
}