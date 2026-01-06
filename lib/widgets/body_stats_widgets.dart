import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 35, bottom: 15, left: 5),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
            color: Colors.orangeAccent,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 3
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final double? value;
  final String target;
  final VoidCallback onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.target,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
              "TARGET: $target",
              style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)
          ),
        ),
        trailing: Text(
          value == null ? "SET" : value.toString(),
          style: TextStyle(
              color: value == null ? Colors.white24 : Colors.orangeAccent,
              fontWeight: FontWeight.w900,
              fontSize: 20,
              fontFamily: 'monospace'
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class PairedStatCard extends StatelessWidget {
  final String title;
  final double? left;
  final double? right;
  final String target;
  final Function(String side) onEdit;

  const PairedStatCard({
    super.key,
    required this.title,
    required this.left,
    required this.right,
    required this.target,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    bool imbalance = (left != null && right != null) && (left! - right!).abs() > 0.5;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      title.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)
                  ),
                  const SizedBox(height: 4),
                  Text(
                      "TARGET: $target",
                      style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
              if (imbalance)
                const Tooltip(
                    message: "Structural Asymmetry Detected",
                    child: Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 22)
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _limbButton("Left", left)),
              const SizedBox(width: 15),
              Expanded(child: _limbButton("Right", right)),
            ],
          )
        ],
      ),
    );
  }

  Widget _limbButton(String side, double? val) {
    return InkWell(
      onTap: () => onEdit(side),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Text(
                side.toUpperCase(),
                style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)
            ),
            const SizedBox(height: 4),
            Text(
              val == null ? "---" : val.toString(),
              style: TextStyle(
                  color: val == null ? Colors.white10 : Colors.orangeAccent,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  fontFamily: 'monospace'
              ),
            ),
          ],
        ),
      ),
    );
  }
}