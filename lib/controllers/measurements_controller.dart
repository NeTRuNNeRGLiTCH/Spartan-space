import 'dart:math';
import '../providers/titan_provider.dart';

class MeasurementsController {
  final TitanProvider provider;

  bool isMale = true;
  Map<String, double?> generalStats = {};
  Map<String, double?> boneStats = {};
  Map<String, double?> muscleStats = {};
  Map<String, Map<String, double?>> pairedStats = {};

  MeasurementsController({
    required this.provider,
  }) {
    syncFromData();
  }

  void syncFromData() {
    final data = provider.bodyData;
    isMale = data['isMale'] ?? true;
    generalStats = {
      "Weight (kg)": data['weight'],
      "Height (cm)": data['height'],
      "Age": data['age'],
      "Body Fat (%)": data['bf'],
    };
    boneStats = {
      "Wrist (cm)": data['wrist'],
      "Ankle (cm)": data['ankle'],
      "Knee (cm)": data['knee'],
    };
    muscleStats = {
      "Neck (cm)": data['neck'],
      "Shoulders (cm)": data['shoulders'],
      "Chest (cm)": data['chest'],
      "Waist (cm)": data['waist'],
      "Hips (cm)": data['hips'],
    };
    pairedStats = {
      "Bicep": {"Left": data['bicepL'], "Right": data['bicepR']},
      "Forearm": {"Left": data['foreL'], "Right": data['foreR']},
      "Thigh": {"Left": data['thighL'], "Right": data['thighR']},
      "Calf": {"Left": data['calfL'], "Right": data['calfR']},
    };
  }

  void toggleGender() {
    isMale = !isMale;
    saveToGlobal();
  }

  String getTarget(String key) {
    double? wrist = boneStats["Wrist (cm)"];
    double? knee = boneStats["Knee (cm)"];
    double? height = generalStats["Height (cm)"];
    double? waist = muscleStats["Waist (cm)"];
    double? hips = muscleStats["Hips (cm)"];

    switch (key) {
      case "Weight (kg)":
        return height != null ? (pow(height / 100, 2) * 22.5).toStringAsFixed(1) : "SET H";
      case "Chest (cm)":
        return wrist != null ? (wrist * 6.5).toStringAsFixed(1) : "SET WRIST";
      case "Neck (cm)":
      case "Bicep":
      case "Calf":
        return wrist != null ? (wrist * 2.5).toStringAsFixed(1) : "SET WRIST";
      case "Forearm (cm)":
        return wrist != null ? (wrist * 2.5 * 0.8).toStringAsFixed(1) : "SET WRIST";
      case "Thigh":
        return knee != null ? (knee * 1.75).toStringAsFixed(1) : "SET KNEE";
      case "Shoulders (cm)":
        return waist != null ? (waist * 1.618).toStringAsFixed(1) : "SET WAIST";
      case "Waist (cm)":
        return !isMale && hips != null
            ? (hips * 0.7).toStringAsFixed(1)
            : (height != null ? (height * 0.45).toStringAsFixed(1) : "SET H");
      default:
        return "---";
    }
  }

  void updateStat(String title, dynamic source, String? side, double? newValue) {
    side != null ? source[side] = newValue : source[title] = newValue;
    saveToGlobal();
  }

  void saveToGlobal() {
    provider.updateBodyData('isMale', isMale);
    generalStats.forEach((k, v) => provider.updateBodyData(_keyMap(k), v));
    boneStats.forEach((k, v) => provider.updateBodyData(_keyMap(k), v));
    muscleStats.forEach((k, v) => provider.updateBodyData(_keyMap(k), v));

    provider.updateBodyData('bicepL', pairedStats["Bicep"]!["Left"]);
    provider.updateBodyData('bicepR', pairedStats["Bicep"]!["Right"]);
    provider.updateBodyData('foreL', pairedStats["Forearm"]!["Left"]);
    provider.updateBodyData('foreR', pairedStats["Forearm"]!["Right"]);
    provider.updateBodyData('thighL', pairedStats["Thigh"]!["Left"]);
    provider.updateBodyData('thighR', pairedStats["Thigh"]!["Right"]);
    provider.updateBodyData('calfL', pairedStats["Calf"]!["Left"]);
    provider.updateBodyData('calfR', pairedStats["Calf"]!["Right"]);
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

  double? get bmi {
    double? w = generalStats["Weight (kg)"];
    double? h = generalStats["Height (cm)"];
    return (w != null && h != null) ? (w / pow(h / 100, 2)) : null;
  }

  double? get bodyFat {
    double? bf = generalStats["Body Fat (%)"];
    if (bf != null) return bf;

    double? h = generalStats["Height (cm)"];
    double? waist = muscleStats["Waist (cm)"];
    double? neck = muscleStats["Neck (cm)"];
    double? hips = muscleStats["Hips (cm)"];

    if (h != null && waist != null && neck != null) {
      return isMale
          ? 495 / (1.0324 - 0.19077 * (log(waist - neck) / ln10) + 0.15456 * (log(h) / ln10)) - 450
          : 495 / (1.29579 - 0.35004 * (log(waist + (hips ?? 0) - neck) / ln10) + 0.22100 * (log(h) / ln10)) - 450;
    }
    return null;
  }

  String get ratioValue {
    double? waist = muscleStats["Waist (cm)"];
    double? shoulders = muscleStats["Shoulders (cm)"];
    double? hips = muscleStats["Hips (cm)"];

    return isMale
        ? (shoulders != null && waist != null ? (shoulders / waist).toStringAsFixed(2) : "--")
        : (waist != null && hips != null ? (waist / hips).toStringAsFixed(2) : "--");
  }
}