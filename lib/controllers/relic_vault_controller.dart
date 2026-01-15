import 'package:flutter/material.dart';
import '../models/relic.dart';
import '../providers/titan_provider.dart';

class RelicVaultController {
  final TitanProvider provider;

  String searchQuery = "";
  bool showLocked = true;
  int sortType = 0;

  RelicVaultController({required this.provider});

  List<Relic> get allRelics => [...Relic.database, ...provider.customRelics];

  bool get isMasterUnlocked => Relic.checkPerfection(provider.bodyData);

  int get unlockedCount => allRelics.where((r) => r.isUnlocked(provider.logs, provider.bodyData)).length;

  double get completionPercent => allRelics.isEmpty ? 0 : unlockedCount / allRelics.length;

  List<Relic> getFilteredRelics() {
    List<Relic> filtered = allRelics.where((r) {
      final unlocked = r.isUnlocked(provider.logs, provider.bodyData);
      bool matchesSearch = r.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          r.description.toLowerCase().contains(searchQuery.toLowerCase());
      bool matchesVisibility = showLocked || unlocked;
      return matchesSearch && matchesVisibility;
    }).toList();

    if (sortType == 1) {
      filtered.sort((a, b) {
        bool aU = a.isUnlocked(provider.logs, provider.bodyData);
        bool bU = b.isUnlocked(provider.logs, provider.bodyData);
        return (aU == bU) ? 0 : (aU ? -1 : 1);
      });
    }
    return filtered;
  }

  void addCustomRelic(String title, String exercise, double weight) {
    final newRelic = CustomRelic(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.toUpperCase(),
      description: "User-defined structural milestone.",
      requirement: "LIFT ${weight}KG IN ${exercise.toUpperCase()}",
      icon: Icons.workspace_premium,
      color: Colors.redAccent,
      targetExercise: exercise,
      targetWeight: weight,
    );
    provider.addCustomRelic(newRelic);
  }
}