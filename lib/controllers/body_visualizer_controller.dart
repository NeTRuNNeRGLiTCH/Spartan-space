import 'dart:math';
import 'package:flutter/material.dart';
import '../providers/titan_provider.dart';

class BodyVisualizerController {
  final TitanProvider provider;

  BodyVisualizerController({required this.provider});

  double _toDouble(dynamic val, double fallback) => (val == null) ? fallback : (val as num).toDouble();

  List<double> calculateTitanRadar() {
    final data = provider.bodyData;
    final logs = provider.logs;

    double weight = _toDouble(data['weight'], 80.0);
    double h = _toDouble(data['height'], 180.0);
    double wrist = _toDouble(data['wrist'], 17.5);

    double leanMass = weight * (1 - (_toDouble(data['bf'], 15.0) / 100.0));
    double ffmi = (leanMass / pow(h / 100.0, 2)) + (6.3 * (1.8 - (h / 100.0)));

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

  Map<String, dynamic> calculateCombatClass(double ffmi, List<double> radar) {
    final data = provider.bodyData;
    double h = _toDouble(data['height'], 180.0);
    double wrist = _toDouble(data['wrist'], 17.5);
    double rRatio = h / (wrist > 0 ? wrist : 17.5);

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

  double getSectorEfficiency(String sector) {
    Map<String, double> scores = {};
    for (var log in provider.logs) {
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
}