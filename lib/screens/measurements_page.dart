import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/body_stats_widgets.dart';

class MeasurementsPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onUpdate;

  const MeasurementsPage({super.key, required this.data, required this.onUpdate});

  @override
  _MeasurementsPageState createState() => _MeasurementsPageState();
}

class _MeasurementsPageState extends State<MeasurementsPage> {
  bool isMale = true;
  late Map<String, double?> _generalStats;
  late Map<String, double?> _boneStats;
  late Map<String, double?> _muscleStats;
  late Map<String, Map<String, double?>> _pairedStats;

  @override
  void initState() {
    super.initState();
    _syncData();
  }

  void _syncData() {
    isMale = widget.data['isMale'] ?? true;
    _generalStats = {
      "Weight (kg)": widget.data['weight'],
      "Height (cm)": widget.data['height'],
      "Age": widget.data['age'],
      "Body Fat (%)": widget.data['bf'],
    };
    _boneStats = {
      "Wrist (cm)": widget.data['wrist'],
      "Ankle (cm)": widget.data['ankle'],
      "Knee (cm)": widget.data['knee'],
    };
    _muscleStats = {
      "Neck (cm)": widget.data['neck'],
      "Shoulders (cm)": widget.data['shoulders'],
      "Chest (cm)": widget.data['chest'],
      "Waist (cm)": widget.data['waist'],
      "Hips (cm)": widget.data['hips'],
    };
    _pairedStats = {
      "Bicep": {"Left": widget.data['bicepL'], "Right": widget.data['bicepR']},
      "Forearm": {"Left": widget.data['foreL'], "Right": widget.data['foreR']},
      "Thigh": {"Left": widget.data['thighL'], "Right": widget.data['thighR']},
      "Calf": {"Left": widget.data['calfL'], "Right": widget.data['calfR']},
    };
  }

  String _getTarget(String key) {
    double? wrist = _boneStats["Wrist (cm)"];
    double? knee = _boneStats["Knee (cm)"];
    double? height = _generalStats["Height (cm)"];
    double? waist = _muscleStats["Waist (cm)"];
    double? hips = _muscleStats["Hips (cm)"];

    switch (key) {
      case "Weight (kg)":
        return height != null ? "${(pow(height/100, 2) * 22.5).toStringAsFixed(1)}" : "SET H";
      case "Chest (cm)":
        return wrist != null ? "${(wrist * 6.5).toStringAsFixed(1)}" : "SET WRIST";
      case "Neck (cm)":
      case "Bicep":
      case "Calf":
        return wrist != null ? "${(wrist * 2.5).toStringAsFixed(1)}" : "SET WRIST";
      case "Forearm (cm)":
        return wrist != null ? "${(wrist * 2.5 * 0.8).toStringAsFixed(1)}" : "SET WRIST";
      case "Thigh":
        return knee != null ? "${(knee * 1.75).toStringAsFixed(1)}" : "SET KNEE";
      case "Shoulders (cm)":
        return waist != null ? "${(waist * 1.618).toStringAsFixed(1)}" : "SET WAIST";
      case "Waist (cm)":
        if (!isMale && hips != null) return "${(hips * 0.7).toStringAsFixed(1)}";
        return height != null ? "${(height * 0.45).toStringAsFixed(1)}" : "SET H";
      default: return "---";
    }
  }

  void _saveToGlobal() {
    widget.data['isMale'] = isMale;
    _generalStats.forEach((k, v) => widget.data[_keyMap(k)] = v);
    _boneStats.forEach((k, v) => widget.data[_keyMap(k)] = v);
    _muscleStats.forEach((k, v) => widget.data[_keyMap(k)] = v);
    widget.data['bicepL'] = _pairedStats["Bicep"]!["Left"];
    widget.data['bicepR'] = _pairedStats["Bicep"]!["Right"];
    widget.data['foreL'] = _pairedStats["Forearm"]!["Left"];
    widget.data['foreR'] = _pairedStats["Forearm"]!["Right"];
    widget.data['thighL'] = _pairedStats["Thigh"]!["Left"];
    widget.data['thighR'] = _pairedStats["Thigh"]!["Right"];
    widget.data['calfL'] = _pairedStats["Calf"]!["Left"];
    widget.data['calfR'] = _pairedStats["Calf"]!["Right"];
    widget.onUpdate();
  }

  String _keyMap(String k) {
    if (k.contains("Weight")) return "weight";
    if (k.contains("Height")) return "height";
    if (k.contains("Age")) return "age";
    if (k.contains("Body Fat")) return "bf";
    if (k.contains("Wrist")) return "wrist";
    if (k.contains("Ankle")) return "ankle";
    if (k.contains("Knee")) return "knee";
    if (k.contains("Neck")) return "neck";
    if (k.contains("Shoulder")) return "shoulders";
    if (k.contains("Chest")) return "chest";
    if (k.contains("Waist")) return "waist";
    if (k.contains("Hips")) return "hips";
    return k;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        title: const Text("BODY ANALYTICS", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isMale ? Icons.male : Icons.female, color: Colors.orangeAccent),
            onPressed: () { setState(() => isMale = !isMale); _saveToGlobal(); },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDashboard(),
          const SectionHeader(title: "Health & Bio"),
          ..._generalStats.keys.map((k) => StatCard(title: k, value: _generalStats[k], target: _getTarget(k), onTap: () => _showEdit(k, _generalStats))),
          const SectionHeader(title: "Joint Anchors"),
          ..._boneStats.keys.map((k) => StatCard(title: k, value: _boneStats[k], target: "N/A", onTap: () => _showEdit(k, _boneStats))),
          const SectionHeader(title: "Torso"),
          ..._muscleStats.keys.map((k) => StatCard(title: k, value: _muscleStats[k], target: _getTarget(k), onTap: () => _showEdit(k, _muscleStats))),
          const SectionHeader(title: "Limbs"),
          ..._pairedStats.keys.map((k) => PairedStatCard(
            title: k,
            left: _pairedStats[k]!["Left"],
            right: _pairedStats[k]!["Right"],
            target: _getTarget(k),
            onEdit: (side) => _showEdit("$side $k", _pairedStats[k]!, side: side),
          )),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    double? w = _generalStats["Weight (kg)"];
    double? h = _generalStats["Height (cm)"];
    double? waist = _muscleStats["Waist (cm)"];
    double? neck = _muscleStats["Neck (cm)"];
    double? shoulders = _muscleStats["Shoulders (cm)"];
    double? hips = _muscleStats["Hips (cm)"];
    double? bmi = (w != null && h != null) ? (w / pow(h / 100, 2)) : null;
    double? bf = _generalStats["Body Fat (%)"];
    if (bf == null && h != null && waist != null && neck != null) {
      bf = isMale
          ? 495 / (1.0324 - 0.19077 * (log(waist - neck) / ln10) + 0.15456 * (log(h) / ln10)) - 450
          : 495 / (1.29579 - 0.35004 * (log(waist + (hips ?? 0) - neck) / ln10) + 0.22100 * (log(h) / ln10)) - 450;
    }
    String rVal = isMale
        ? (shoulders != null && waist != null ? (shoulders / waist).toStringAsFixed(2) : "--")
        : (waist != null && hips != null ? (waist / hips).toStringAsFixed(2) : "--");

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.orangeAccent.withOpacity(0.2))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _dashMetric("BMI", bmi?.toStringAsFixed(1) ?? "--", (bmi ?? 0) > 25 ? Colors.redAccent : Colors.greenAccent),
          _dashMetric("BF%", bf?.toStringAsFixed(1) ?? "--", (bf ?? 0) > 20 ? Colors.orangeAccent : Colors.greenAccent),
          _dashMetric(isMale ? "V-TAPER" : "WHR", rVal, Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _dashMetric(String l, String v, Color c) => Column(children: [
    Text(v, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: c)),
    Text(l, style: const TextStyle(fontSize: 10, color: Colors.white70, letterSpacing: 2, fontWeight: FontWeight.bold)),
  ]);

  void _showEdit(String title, dynamic source, {String? side}) {
    double? currentVal = (side != null) ? source[side] : source[title];
    TextEditingController controller = TextEditingController(text: currentVal?.toString() ?? "");
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
          TextButton(onPressed: () { setState(() { if (side != null) source[side] = null; else source[title] = null; }); _saveToGlobal(); Navigator.pop(ctx); }, child: const Text("CLEAR", style: TextStyle(color: Colors.redAccent))),
          TextButton(onPressed: () { setState(() { if (side != null) source[side] = double.tryParse(controller.text); else source[title] = double.tryParse(controller.text); }); _saveToGlobal(); Navigator.pop(ctx); }, child: const Text("SAVE", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}