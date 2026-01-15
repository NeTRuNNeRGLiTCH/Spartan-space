import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/titan_provider.dart';
import '../controllers/relic_vault_controller.dart';
import '../widgets/relic_widgets.dart';

class RelicVaultPage extends StatefulWidget {
  const RelicVaultPage({super.key});

  @override
  State<RelicVaultPage> createState() => _RelicVaultPageState();
}

class _RelicVaultPageState extends State<RelicVaultPage> {
  late RelicVaultController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RelicVaultController(
      provider: context.read<TitanProvider>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<TitanProvider>();
    final filtered = _controller.getFilteredRelics();

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
              percent: _controller.completionPercent,
              text: "${_controller.unlockedCount} / ${_controller.allRelics.length} DATA-RELICS"
          ),
          VaultControlBar(
            onSearch: (v) => setState(() => _controller.searchQuery = v),
            onToggleHide: () => setState(() => _controller.showLocked = !_controller.showLocked),
            showLocked: _controller.showLocked,
            onSort: () => setState(() => _controller.sortType = _controller.sortType == 0 ? 1 : 0),
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
                final u = r.isUnlocked(_controller.provider.logs, _controller.provider.bodyData);
                return GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    backgroundColor: const Color(0xFF0F0F0F),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
                    builder: (ctx) => RelicDetailView(relic: r, unlocked: u),
                  ),
                  child: RelicTile(relic: r, unlocked: u),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _controller.isMasterUnlocked
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
                _controller.addCustomRelic(
                  titleCtrl.text,
                  exCtrl.text,
                  double.tryParse(weightCtrl.text) ?? 0,
                );
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