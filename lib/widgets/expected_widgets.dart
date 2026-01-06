import 'package:flutter/material.dart';

class GoalFolderTile extends StatelessWidget {
  final String title;
  final int current;
  final int total;
  final VoidCallback onManage;
  final List<Widget> children;

  const GoalFolderTile({
    super.key,
    required this.title,
    required this.current,
    required this.total,
    required this.onManage,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: const Icon(Icons.ads_click, color: Colors.orangeAccent),
        title: Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        subtitle: Text("Session $current of $total", style: const TextStyle(fontSize: 10, color: Colors.white38)),
        trailing: IconButton(icon: const Icon(Icons.more_vert), onPressed: onManage),
        childrenPadding: const EdgeInsets.only(left: 20, right: 10, bottom: 10),
        children: children,
      ),
    );
  }
}

class GoalExerciseTile extends StatelessWidget {
  final String title;
  final double nextWeight;
  final VoidCallback onEdit;

  const GoalExerciseTile({super.key, required this.title, required this.nextWeight, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF111111),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text("Next Target: ${nextWeight.toStringAsFixed(1)} kg",
            style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
        trailing: IconButton(icon: const Icon(Icons.tune, size: 18, color: Colors.white24), onPressed: onEdit),
      ),
    );
  }
}