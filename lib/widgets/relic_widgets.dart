import 'package:flutter/material.dart';
import '../models/relic.dart';

class VaultHeader extends StatelessWidget {
  final double percent;
  final String text;

  const VaultHeader({
    super.key,
    required this.percent,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    Color glowColor = Color.lerp(Colors.orangeAccent, Colors.cyanAccent, percent) ?? Colors.orangeAccent;
    if (percent >= 1.0) glowColor = Colors.greenAccent;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    )
                  ],
                ),
              ),
              SizedBox(
                width: 90, height: 90,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 3,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(glowColor),
                ),
              ),
              Text(
                "${(percent * 100).toInt()}%",
                style: TextStyle(
                  color: glowColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            "TOTAL SYNCHRONIZATION",
            style: TextStyle(
                color: Colors.white70,
                fontSize: 9,
                letterSpacing: 4,
                fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900
            ),
          ),
        ],
      ),
    );
  }
}

class VaultControlBar extends StatelessWidget {
  final Function(String) onSearch;
  final VoidCallback onToggleHide;
  final VoidCallback onSort;
  final bool showLocked;

  const VaultControlBar({
    super.key,
    required this.onSearch,
    required this.onToggleHide,
    required this.onSort,
    required this.showLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: onSearch,
              style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: "FILTER ARCHIVE",
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                filled: true,
                fillColor: const Color(0xFF111111),
                contentPadding: EdgeInsets.zero,
                prefixIcon: const Icon(Icons.search, size: 18, color: Colors.white54),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _iconButton(
              showLocked ? Icons.visibility : Icons.visibility_off,
              onToggleHide,
              showLocked ? Colors.orangeAccent : Colors.white38
          ),
          const SizedBox(width: 10),
          _iconButton(Icons.sort, onSort, Colors.white54),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback tap, Color color) => GestureDetector(
    onTap: tap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Icon(icon, size: 18, color: color),
    ),
  );
}

class RelicTile extends StatelessWidget {
  final Relic relic;
  final bool unlocked;

  const RelicTile({super.key, required this.relic, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: unlocked ? relic.color.withOpacity(0.5) : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
              relic.icon,
              color: unlocked ? relic.color : Colors.white.withOpacity(0.2),
              size: 28
          ),
          const Spacer(),
          Text(
            unlocked ? relic.title : "ENCRYPTED",
            style: TextStyle(
              color: unlocked ? Colors.white : Colors.white54,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 2,
            width: 30,
            color: unlocked ? relic.color : Colors.white.withOpacity(0.1),
          ),
        ],
      ),
    );
  }
}

class RelicDetailView extends StatelessWidget {
  final Relic relic;
  final bool unlocked;

  const RelicDetailView({super.key, required this.relic, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F0F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
              relic.icon,
              color: unlocked ? relic.color : Colors.white24,
              size: 70
          ),
          const SizedBox(height: 25),
          Text(
            unlocked ? relic.title : "LOCKED DATA-RELIC",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            unlocked
                ? relic.description
                : "Historical archive access denied. System must reach specified biological or structural thresholds to initialize extraction.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
          ),
          const Divider(height: 60, color: Colors.white12),
          const Text(
            "SYSTEM REQUIREMENT",
            style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              relic.requirement,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: unlocked ? relic.color : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}