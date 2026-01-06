import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BiometricSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const BiometricSectionHeader({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.orangeAccent, size: 16),
          const SizedBox(width: 10),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Divider(color: Colors.white.withOpacity(0.15), thickness: 1)),
        ],
      ),
    );
  }
}

class StatusMatrix extends StatelessWidget {
  final List<Map<String, dynamic>> badges;
  const StatusMatrix({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: badges.length,
        itemBuilder: (context, i) => Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: badges[i]['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: badges[i]['color'].withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              badges[i]['label'].toUpperCase(),
              style: TextStyle(color: badges[i]['color'], fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
          ),
        ),
      ),
    );
  }
}

class ArchetypeModule extends StatelessWidget {
  final String name;
  final String chassis;
  final String description;
  final Color color;

  const ArchetypeModule({super.key, required this.name, required this.chassis, required this.description, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.02), blurRadius: 20, spreadRadius: 5)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("CLASS: $chassis", style: const TextStyle(color: Colors.white54, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 2)),
              Icon(Icons.shield_outlined, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 10),
          Text(name, style: TextStyle(color: color, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1.5)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.4, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

class DataGridTile extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final Color color;

  const DataGridTile({super.key, required this.label, required this.value, required this.trend, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(trend, style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class EquilibriumPolygon extends StatelessWidget {
  final List<double> points;
  const EquilibriumPolygon({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          dataSets: [
            RadarDataSet(
              fillColor: Colors.orangeAccent.withOpacity(0.15),
              borderColor: Colors.orangeAccent,
              borderWidth: 2,
              entryRadius: 3,
              dataEntries: points.map((p) => RadarEntry(value: p)).toList(),
            ),
          ],
          getTitle: (index, angle) {
            const titles = ["PWR", "SYM", "GAP", "SNG", "DLT", "RAR"];
            return RadarChartTitle(text: titles[index], angle: angle);
          },
          titleTextStyle: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
          tickCount: 3,
          gridBorderData: BorderSide(color: Colors.white.withOpacity(0.1)),
          ticksTextStyle: const TextStyle(color: Colors.transparent),
        ),
      ),
    );
  }
}

class EvolutionBar extends StatelessWidget {
  final String label;
  final double current;
  final double limit;
  const EvolutionBar({super.key, required this.label, required this.current, required this.limit});

  @override
  Widget build(BuildContext context) {
    double progress = (limit > 0) ? (current / limit).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label.toUpperCase(), style: const TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              Text("${(progress * 100).toInt()}%", style: const TextStyle(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: Colors.white.withOpacity(0.05),
              color: Colors.orangeAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class DensityGauge extends StatelessWidget {
  final String muscle;
  final double score;
  const DensityGauge({super.key, required this.muscle, required this.score});

  @override
  Widget build(BuildContext context) {
    Color color = score > 2.5 ? Colors.purpleAccent : score > 1.8 ? Colors.greenAccent : Colors.blueGrey;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.psychology, color: color, size: 18),
          const SizedBox(width: 15),
          Expanded(
            child: Text(muscle.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          Text(
            score.toStringAsFixed(2),
            style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}