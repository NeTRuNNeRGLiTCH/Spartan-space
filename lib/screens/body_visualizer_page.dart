import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/titan_provider.dart';
import '../controllers/body_visualizer_controller.dart';
import '../widgets/body_painter.dart';

class BodyVisualizerPage extends StatefulWidget {
  const BodyVisualizerPage({super.key});

  @override
  State<BodyVisualizerPage> createState() => _BodyVisualizerPageState();
}

class _BodyVisualizerPageState extends State<BodyVisualizerPage> {
  late BodyVisualizerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BodyVisualizerController(
      provider: context.read<TitanProvider>(),
    );
  }

  double _toDouble(dynamic val, double fallback) => (val == null) ? fallback : (val as num).toDouble();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TitanProvider>();
    final data = provider.bodyData;
    final isMale = data['isMale'] ?? true;

    final h = _toDouble(data['height'], 180.0);
    final w = _toDouble(data['weight'], 80.0);
    final bf = _toDouble(data['bf'], 15.0);
    final wrist = _toDouble(data['wrist'], 17.5);
    final ankle = _toDouble(data['ankle'], 22.5);
    final shoulders = _toDouble(data['shoulders'], 115.0);
    final waist = _toDouble(data['waist'], 80.0);

    final leanMass = w * (1 - (bf / 100.0));
    final rawFfmi = (leanMass / pow(h / 100.0, 2)) + (6.3 * (1.8 - (h / 100.0)));
    final rRatio = h / (wrist > 0 ? wrist : 17.5);

    final radarPoints = _controller.calculateTitanRadar();
    final combatClass = _controller.calculateCombatClass(rawFfmi, radarPoints);

    final upperM = isMale ? 1.0 : 0.84;
    final lowerM = isMale ? 1.0 : 0.96;
    final maxTorso = (1.68 * wrist + 1.37 * ankle + 0.385 * h) * upperM;
    final maxArm = (0.12 * h + 0.5 * wrist) * upperM;
    final maxThigh = (0.14 * h + 0.6 * ankle) * lowerM;

    final torsoDens = (_controller.getSectorEfficiency("Torso") / (max(1.0, _toDouble(data['chest'], 1.0)))) * 1.0;
    final limbDens = (_controller.getSectorEfficiency("Limbs") / (max(1.0, _toDouble(data['bicepL'], 1.0)))) * 2.5;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        title: const Text("TITAN TELEMETRY", style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w900, fontSize: 11, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          DensityGauge(muscle: "Foundation Drive", score: (_controller.getSectorEfficiency("Foundation") / max(1.0, _toDouble(data['thighL'], 1.0))) * 0.6),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}