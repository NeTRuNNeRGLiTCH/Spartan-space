import 'dart:math';
import 'package:flutter/material.dart';
import '../models/workout_log.dart';
import '../models/workout_node.dart';
import '../widgets/body_painter.dart';

class BodyVisualizerPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final List<WorkoutLog> logs;

  const BodyVisualizerPage({super.key, required this.data, required this.logs});

  double _toDouble(dynamic val, double fallback) => (val == null) ? fallback : (val as num).toDouble();

  List<double> _calculateTitanRadar(double weight, double h, double wrist, double ffmi) {
    double peak1RM = 0.0;
    for (var l in logs) {
      for (var s in l.performedSets) {
        if (s.weight > 0) {
          double r = s.weight * (1 + (s.value / 30.0));
          if (r > peak1RM) peak1RM = r;
        }
      }
    }
    double pwr = (peak1RM / (max(1.0, weight) * 1.8)).clamp(0.1, 1.0);

    List<String> pairs = ["bicep", "fore", "thigh", "calf"];
    double totalImb = 0.0;
    List<double> deltas = [];
    for (var p in pairs) {
      double d = (_toDouble(data['${p}L'], 0.0) - _toDouble(data['${p}R'], 0.0)).abs();
      deltas.add(d);
      totalImb += d;
    }
    double sym = (1.0 - (totalImb / 5.0)).clamp(0.1, 1.0);
    double gap = (ffmi / 25.0).clamp(0.1, 1.0);
    double sng = (1.0 - (pwr - gap).abs()).clamp(0.1, 1.0);
    double maxD = deltas.isNotEmpty ? deltas.reduce(max) : 0.0;
    double dlt = (1.0 - (maxD / 3.0)).clamp(0.1, 1.0);

    double rRatio = h / (wrist > 0 ? wrist : 17.5);
    double frameOutlier = (rRatio - 10.0).abs() * 0.4;
    double massOutlier = (ffmi - 19.0).abs() * 0.1;
    double rarity = (0.2 + frameOutlier + massOutlier + (pwr * 0.3)).clamp(0.1, 1.0);

    return [pwr, sym, gap, sng, dlt, rarity];
  }

  Map<String, dynamic> _calculateCombatClass(double rRatio, double ffmi, List<double> radar) {
    if (ffmi < 19.0) {
      return {
        "name": "THE GENESIS",
        "trait": "Foundational phase. System initializing skeletal-muscular sync.",
        "color": Colors.white54
      };
    }
    if (rRatio > 10.4 && radar[5] > 0.6) {
      return {
        "name": "THE PEAK",
        "trait": "Small chassis optimized for extreme tissue density and visual impact.",
        "color": Colors.cyanAccent
      };
    }
    if (rRatio < 9.6 && ffmi > 22.0) {
      return {
        "name": "THE HYBRID",
        "trait": "Heavy-duty frame. Built for absolute power and high-load capacity.",
        "color": Colors.redAccent
      };
    }
    if (radar[3] > 0.8 && radar[1] > 0.8) {
      return {
        "name": "THE PARAGON",
        "trait": "Titan Singularity achieved. Harmony between power and proportion.",
        "color": Colors.greenAccent
      };
    }
    return {
      "name": "THE TITAN",
      "trait": "Advanced biological asset. System performing at high-efficiency thresholds.",
      "color": Colors.orangeAccent
    };
  }

  double _getSectorEfficiency(String sector) {
    Map<String, double> scores = {};
    for (var log in logs) {
      String m = log.muscleGroup?.toLowerCase() ?? "";
      bool match = (sector == "Torso" && (m == "chest" || m == "back")) ||
          (sector == "Limbs" && (m == "arms" || m == "shoulders")) ||
          (sector == "Foundation" && (m == "legs" || m == "glutes"));
      if (match) {
        double peak = 0.0;
        for (var s in log.performedSets) {
          if (s.weight > 0) {
            double cur = s.weight * (1 + (s.value / 30.0));
            if (cur > peak) peak = cur;
          }
        }
        if (peak > (scores[log.exerciseName] ?? 0.0)) scores[log.exerciseName] = peak;
      }
    }
    if (scores.isEmpty) return 0.0;
    List<double> values = scores.values.toList()..sort((a, b) => b.compareTo(a));
    return values.length >= 2 ? (values[0] + values[1]) / 2.0 : values[0];
  }

  @override
  Widget build(BuildContext context) {
    bool isMale = data['isMale'] ?? true;
    double h = _toDouble(data['height'], 180.0);
    double w = _toDouble(data['weight'], 80.0);
    double bf = _toDouble(data['bf'], 15.0);
    double wrist = _toDouble(data['wrist'], 17.5);
    double ankle = _toDouble(data['ankle'], 22.5);
    double shoulders = _toDouble(data['shoulders'], 115.0);
    double waist = _toDouble(data['waist'], 80.0);

    double leanMass = w * (1 - (bf / 100.0));
    double rawFfmi = (leanMass / pow(h / 100.0, 2)) + (6.3 * (1.8 - (h / 100.0)));
    double rRatio = h / (wrist > 0 ? wrist : 17.5);
    List<double> radarPoints = _calculateTitanRadar(w, h, wrist, rawFfmi);
    var combatClass = _calculateCombatClass(rRatio, rawFfmi, radarPoints);

    final double upperM = isMale ? 1.0 : 0.84;
    final double lowerM = isMale ? 1.0 : 0.96;
    double maxTorso = (1.68 * wrist + 1.37 * ankle + 0.385 * h) * upperM;
    double maxArm = (0.12 * h + 0.5 * wrist) * upperM;
    double maxThigh = (0.14 * h + 0.6 * ankle) * lowerM;

    double torsoDens = (_getSectorEfficiency("Torso") / (max(1.0, _toDouble(data['chest'], 1.0)))) * 1.0;
    double limbDens = (_getSectorEfficiency("Limbs") / (max(1.0, _toDouble(data['bicepL'], 1.0)))) * 2.5;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        title: const Text("TITAN TELEMETRY", style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w900, fontSize: 11, color: Colors.white)),
        centerTitle: true, backgroundColor: Colors.transparent, elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        children: [
          StatusMatrix(badges: [
            {"label": combatClass['name'], "color": combatClass['color']},
            {"label": "RARITY: ${(radarPoints[5] * 100).toInt()}%", "color": Colors.cyanAccent},
            {"label": "SINGULARITY: ${(radarPoints[3] * 100).toInt()}%", "color": Colors.purpleAccent},
          ]),
          const SizedBox(height: 10),
          ArchetypeModule(
            name: combatClass['name'],
            chassis: rRatio > 10.4 ? "LIGHT" : rRatio >= 9.6 ? "STANDARD" : "HEAVY",
            description: combatClass['trait'],
            color: combatClass['color'],
          ),
          const SizedBox(height: 25),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: [
              DataGridTile(label: "SYSTEM FFMI", value: rawFfmi.toStringAsFixed(1), trend: "CAP: 25.0", color: Colors.orangeAccent),
              DataGridTile(label: "V-TAPER", value: (shoulders / max(1, waist)).toStringAsFixed(2), trend: "RATIO", color: Colors.blueAccent),
              DataGridTile(label: "BONE:MUSCLE", value: (leanMass / (wrist + ankle)).toStringAsFixed(1), trend: "DENSITY", color: Colors.greenAccent),
              DataGridTile(label: "LEAN ASSET", value: "${leanMass.toInt()}KG", trend: "ACTIVE", color: Colors.white),
            ],
          ),
          const BiometricSectionHeader(title: "Equilibrium Analysis", icon: Icons.hub_outlined),
          EquilibriumPolygon(points: radarPoints),
          const BiometricSectionHeader(title: "Structural Evolution", icon: Icons.architecture),
          EvolutionBar(label: "Torso", current: _toDouble(data['chest'], 0.0), limit: maxTorso),
          DensityGauge(muscle: "Torso Drive", score: torsoDens),
          const SizedBox(height: 10),
          EvolutionBar(label: "Limbs", current: _toDouble(data['bicepL'], 0.0), limit: maxArm),
          DensityGauge(muscle: "Limb Drive", score: limbDens),
          const SizedBox(height: 10),
          EvolutionBar(label: "Foundation", current: _toDouble(data['thighL'], 0.0), limit: maxThigh),
          DensityGauge(muscle: "Foundation Drive", score: (_getSectorEfficiency("Foundation") / max(1.0, _toDouble(data['thighL'], 1.0))) * 0.6),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}