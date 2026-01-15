import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/body_stats_widgets.dart';
import '../controllers/measurements_controller.dart';
import '../providers/titan_provider.dart';

class MeasurementsPage extends StatefulWidget {
  const MeasurementsPage({super.key});

  @override
  _MeasurementsPageState createState() => _MeasurementsPageState();
}

class _MeasurementsPageState extends State<MeasurementsPage> {
  late MeasurementsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MeasurementsController(
      provider: context.read<TitanProvider>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<TitanProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        title: const Text("BODY ANALYTICS",
            style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
                _controller.isMale ? Icons.male : Icons.female,
                color: Colors.orangeAccent
            ),
            onPressed: () => setState(() => _controller.toggleGender()),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDashboard(),
          const SectionHeader(title: "Health & Bio"),
          ..._controller.generalStats.keys.map((k) => StatCard(
              title: k,
              value: _controller.generalStats[k],
              target: _controller.getTarget(k),
              onTap: () => _showEdit(k, _controller.generalStats)
          )),
          const SectionHeader(title: "Joint Anchors"),
          ..._controller.boneStats.keys.map((k) => StatCard(
              title: k,
              value: _controller.boneStats[k],
              target: "N/A",
              onTap: () => _showEdit(k, _controller.boneStats)
          )),
          const SectionHeader(title: "Torso"),
          ..._controller.muscleStats.keys.map((k) => StatCard(
              title: k,
              value: _controller.muscleStats[k],
              target: _controller.getTarget(k),
              onTap: () => _showEdit(k, _controller.muscleStats)
          )),
          const SectionHeader(title: "Limbs"),
          ..._controller.pairedStats.keys.map((k) => PairedStatCard(
            title: k,
            left: _controller.pairedStats[k]!["Left"],
            right: _controller.pairedStats[k]!["Right"],
            target: _controller.getTarget(k),
            onEdit: (side) => _showEdit("$side $k", _controller.pairedStats[k]!, side: side),
          )),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final bmi = _controller.bmi;
    final bf = _controller.bodyFat;

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
          color: Colors.orangeAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.orangeAccent.withOpacity(0.2))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _dashMetric(
              "BMI",
              bmi?.toStringAsFixed(1) ?? "--",
              (bmi ?? 0) > 25 ? Colors.redAccent : Colors.greenAccent
          ),
          _dashMetric(
              "BF%",
              bf?.toStringAsFixed(1) ?? "--",
              (bf ?? 0) > 20 ? Colors.orangeAccent : Colors.greenAccent
          ),
          _dashMetric(
              _controller.isMale ? "V-TAPER" : "WHR",
              _controller.ratioValue,
              Colors.blueAccent
          ),
        ],
      ),
    );
  }

  Widget _dashMetric(String l, String v, Color c) => Column(children: [
    Text(v, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: c)),
    Text(l, style: const TextStyle(fontSize: 10, color: Colors.white70, letterSpacing: 2, fontWeight: FontWeight.bold)),
  ]);

  void _showEdit(String title, dynamic source, {String? side}) {
    final double? currentVal = (side != null) ? source[side] : source[title];
    final controller = TextEditingController(text: currentVal?.toString() ?? "");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text("UPDATE $title", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orangeAccent)),
              labelText: "MEASUREMENT (CM/KG)",
              labelStyle: TextStyle(color: Colors.white38, fontSize: 10)
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                setState(() => _controller.updateStat(title, source, side, null));
                Navigator.pop(ctx);
              },
              child: const Text("CLEAR", style: TextStyle(color: Colors.redAccent))
          ),
          TextButton(
              onPressed: () {
                setState(() => _controller.updateStat(title, source, side, double.tryParse(controller.text)));
                Navigator.pop(ctx);
              },
              child: const Text("SAVE", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }
}