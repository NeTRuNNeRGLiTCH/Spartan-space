import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsToggle extends StatelessWidget {
  final int currentIndex;
  final Function(int) onSelected;

  const AnalyticsToggle({super.key, required this.currentIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      child: Row(
        children: [
          _btn(0, "RECORDS"),
          const SizedBox(width: 8),
          _btn(1, "TREND"),
          const SizedBox(width: 8),
          _btn(2, "ACTIVITY"),
        ],
      ),
    );
  }

  Widget _btn(int index, String label) {
    bool isSelected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelected(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orangeAccent : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? Colors.orangeAccent : Colors.white10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RecordCard extends StatelessWidget {
  final String title;
  final double weight;

  const RecordCard({super.key, required this.title, required this.weight});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: Icon(Icons.star, color: weight > 0 ? Colors.orangeAccent : Colors.white24, size: 20),
        title: Text(
            title.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white, letterSpacing: 0.5)
        ),
        trailing: Text(
          weight > 0 ? "${weight.toStringAsFixed(1)}kg" : "---",
          style: TextStyle(
              color: weight > 0 ? Colors.white : Colors.white24,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              fontFamily: 'monospace'
          ),
        ),
      ),
    );
  }
}

class NeonChartContainer extends StatelessWidget {
  final Widget chart;
  final String title;

  const NeonChartContainer({super.key, required this.chart, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 320,
          width: double.infinity,
          padding: const EdgeInsets.only(right: 25, top: 25, bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: chart,
        ),
        const SizedBox(height: 15),
        Text(
            title.toUpperCase(),
            style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 3, fontWeight: FontWeight.bold)
        ),
      ],
    );
  }
}

class MuscleFocusChart extends StatelessWidget {
  final Map<String, int> distribution;
  final Color Function(String) getColor;

  const MuscleFocusChart({super.key, required this.distribution, required this.getColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 5,
                centerSpaceRadius: 40,
                sections: distribution.entries.map((e) => PieChartSectionData(
                  color: getColor(e.key),
                  value: e.value.toDouble(),
                  title: '',
                  radius: 45,
                )).toList(),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Wrap(
            spacing: 15,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: distribution.keys.map((m) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: getColor(m), shape: BoxShape.circle)
                ),
                const SizedBox(width: 8),
                Text(
                    m.toUpperCase(),
                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)
                ),
              ],
            )).toList(),
          )
        ],
      ),
    );
  }
}