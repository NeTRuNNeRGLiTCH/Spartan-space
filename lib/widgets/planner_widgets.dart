import 'package:flutter/material.dart';

class PlannerPlanCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final bool isPressing;
  final VoidCallback onTap;
  final VoidCallback onSettings;

  const PlannerPlanCard({
    super.key,
    required this.title,
    required this.isSelected,
    required this.isPressing,
    required this.onTap,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isPressing ? 1.05 : (isSelected ? 1.0 : 0.85),
        duration: const Duration(milliseconds: 150),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orangeAccent : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(25),
            boxShadow: isSelected ? [
              BoxShadow(color: Colors.orangeAccent.withOpacity(0.2), blurRadius: 20)
            ] : [],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.bolt, color: isSelected ? Colors.black : Colors.orangeAccent),
                  IconButton(
                    icon: Icon(Icons.settings, color: isSelected ? Colors.black : Colors.white24),
                    onPressed: onSettings,
                  )
                ],
              ),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.black : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlannerFolderTile extends StatelessWidget {
  final String title;
  final VoidCallback onManage;
  final List<Widget> children;

  const PlannerFolderTile({
    super.key,
    required this.title,
    required this.onManage,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ExpansionTile(
        leading: const Icon(Icons.folder_open, color: Colors.blueAccent, size: 20),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white24),
          onPressed: onManage,
        ),
        childrenPadding: const EdgeInsets.only(left: 20, right: 10, bottom: 10),
        children: children,
      ),
    );
  }
}

class PlannerExerciseTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onEdit;

  const PlannerExerciseTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF161616),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.fitness_center, color: Colors.orangeAccent, size: 18),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white24)),
        trailing: IconButton(
          icon: const Icon(Icons.tune, size: 18, color: Colors.white38),
          onPressed: onEdit,
        ),
      ),
    );
  }
}