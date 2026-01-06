import 'package:flutter/material.dart';
import '../models/relic.dart';
import '../models/workout_log.dart';
import '../widgets/relic_widgets.dart';

class RelicVaultPage extends StatefulWidget {
  final List<WorkoutLog> logs;
  final Map<String, dynamic> bodyData;
  final List<CustomRelic> customRelics;
  final VoidCallback onUpdate;

  const RelicVaultPage({
    super.key,
    required this.logs,
    required this.bodyData,
    required this.customRelics,
    required this.onUpdate,
  });

  @override
  State<RelicVaultPage> createState() => _RelicVaultPageState();
}

class _RelicVaultPageState extends State<RelicVaultPage> {
  String _searchQuery = "";
  bool _showLocked = true;
  int _sortType = 0;

  @override
  Widget build(BuildContext context) {
    final List<Relic> allRelics = [...Relic.database, ...widget.customRelics];
    bool isMasterUnlocked = Relic.checkPerfection(widget.bodyData);
    int unlockedCount = allRelics.where((r) => r.isUnlocked(widget.logs, widget.bodyData)).length;
    double completion = allRelics.isEmpty ? 0 : unlockedCount / allRelics.length;

    List<Relic> filtered = allRelics.where((r) {
      final unlocked = r.isUnlocked(widget.logs, widget.bodyData);
      bool matchesSearch = r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.description.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesVisibility = _showLocked || unlocked;
      return matchesSearch && matchesVisibility;
    }).toList();

    if (_sortType == 1) {
      filtered.sort((a, b) {
        bool aU = a.isUnlocked(widget.logs, widget.bodyData);
        bool bU = b.isUnlocked(widget.logs, widget.bodyData);
        return (aU == bU) ? 0 : (aU ? -1 : 1);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        title: const Text("RELIC VAULT",
            style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          VaultHeader(
              percent: completion,
              text: "$unlockedCount / ${allRelics.length} DATA-RELICS"
          ),
          VaultControlBar(
            onSearch: (v) => setState(() => _searchQuery = v),
            onToggleHide: () => setState(() => _showLocked = !_showLocked),
            showLocked: _showLocked,
            onSort: () => setState(() => _sortType = _sortType == 0 ? 1 : 0),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                child: Text("NO DATA MATCHES ARCHIVE QUERY",
                    style: TextStyle(color: Colors.white38, letterSpacing: 2, fontSize: 10, fontWeight: FontWeight.bold)))
                : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.9,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final r = filtered[i];
                final u = r.isUnlocked(widget.logs, widget.bodyData);
                return GestureDetector(
                  onTap: () => _showRelicInfo(context, r, u),
                  child: RelicTile(relic: r, unlocked: u),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isMasterUnlocked
          ? FloatingActionButton.extended(
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.add_moderator, color: Colors.black),
        label: const Text("ENGRAVE CUSTOM RELIC",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
        onPressed: () => _showRelicForgeDialog(),
      )
          : null,
    );
  }

  void _showRelicInfo(BuildContext context, Relic r, bool u) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0F0F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => RelicDetailView(relic: r, unlocked: u),
    );
  }

  void _showRelicForgeDialog() {
    final titleCtrl = TextEditingController();
    final exCtrl = TextEditingController();
    final weightCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("RELIC FORGE",
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Specify a unique strength target to encode into your personal archive.",
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(height: 15),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: "RELIC TITLE",
                  labelStyle: TextStyle(color: Colors.white54),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
                ),
              ),
              TextField(
                controller: exCtrl,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: "TARGET EXERCISE",
                  labelStyle: TextStyle(color: Colors.white54),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
                ),
              ),
              TextField(
                controller: weightCtrl,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: "TARGET WEIGHT (KG)",
                  labelStyle: TextStyle(color: Colors.white54),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("ABORT", style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              if (titleCtrl.text.isNotEmpty && exCtrl.text.isNotEmpty && weightCtrl.text.isNotEmpty) {
                final newCustomRelic = CustomRelic(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleCtrl.text.toUpperCase(),
                  description: "User-defined structural milestone.",
                  requirement: "LIFT ${weightCtrl.text}KG IN ${exCtrl.text.toUpperCase()}",
                  icon: Icons.workspace_premium,
                  color: Colors.redAccent,
                  targetExercise: exCtrl.text,
                  targetWeight: double.tryParse(weightCtrl.text) ?? 0,
                );
                setState(() => widget.customRelics.add(newCustomRelic));
                widget.onUpdate();
                Navigator.pop(ctx);
              }
            },
            child: const Text("ENGRAVE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}