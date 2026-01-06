import 'package:flutter/material.dart';

class RoutineHeader extends StatelessWidget {
  final String title;
  const RoutineHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25, top: 40, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            "ACTIVE PROTOCOL",
            style: TextStyle(
              color: Colors.white30,
              letterSpacing: 6,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              color: Colors.white,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class RoutineExerciseCard extends StatelessWidget {
  final String title;
  final String muscle;
  final bool isRoadmap;
  final String? roadmapTarget;
  final List<Widget> setRows;
  final VoidCallback onManageLogic;

  const RoutineExerciseCard({
    super.key,
    required this.title,
    required this.muscle,
    this.isRoadmap = false,
    this.roadmapTarget,
    required this.setRows,
    required this.onManageLogic,
  });

  @override
  Widget build(BuildContext context) {
    Color accentColor = isRoadmap ? Colors.blueAccent : Colors.orangeAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: accentColor.withOpacity(isRoadmap ? 0.3 : 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)
                  ),
                  Text(
                      muscle.toUpperCase(),
                      style: TextStyle(color: accentColor, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)
                  ),
                ],
              ),
              isRoadmap
                  ? Icon(Icons.track_changes_rounded, color: accentColor, size: 22)
                  : IconButton(
                icon: Icon(Icons.settings_input_component, color: accentColor, size: 20),
                onPressed: onManageLogic,
              ),
            ],
          ),

          if (isRoadmap && roadmapTarget != null)
            Container(
              margin: const EdgeInsets.only(top: 15),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.bolt, color: accentColor, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    roadmapTarget!,
                    style: TextStyle(color: accentColor, fontWeight: FontWeight.w900, fontSize: 11),
                  ),
                ],
              ),
            ),

          const Divider(color: Colors.white10, height: 40),

          ...setRows,
        ],
      ),
    );
  }
}

class RoutineSetRow extends StatelessWidget {
  final int index;
  final Widget repsWidget;
  final Widget weightWidget;

  const RoutineSetRow({
    super.key,
    required this.index,
    required this.repsWidget,
    required this.weightWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Text(
                "${index + 1}",
                style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)
            ),
          ),
          const SizedBox(width: 15),
          const Text(
              "ACTUAL",
              style: TextStyle(color: Colors.white10, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)
          ),
          const Spacer(),
          repsWidget,
          const SizedBox(width: 10),
          weightWidget,
        ],
      ),
    );
  }
}

class FinishWorkoutButton extends StatelessWidget {
  final VoidCallback onPressed;
  const FinishWorkoutButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF050505),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.03))),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orangeAccent,
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 20,
          shadowColor: Colors.orangeAccent.withOpacity(0.4),
        ),
        onPressed: onPressed,
        child: const Text(
          "FINISH & OPTIMIZE",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              fontSize: 16
          ),
        ),
      ),
    );
  }
}