import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/custom_protocol.dart';
import '../services/titan_engine/titan_engine.dart';
import '../controllers/protocol_controller.dart';
import '../providers/titan_provider.dart';
import 'codex_page.dart';
import '../services/protocol_library_service.dart';

class ProtocolEditorPage extends StatefulWidget {
  const ProtocolEditorPage({super.key});

  @override
  State<ProtocolEditorPage> createState() => _ProtocolEditorPageState();
}

class _ProtocolEditorPageState extends State<ProtocolEditorPage> {
  late ProtocolController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProtocolController(
      provider: context.read<TitanProvider>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<TitanProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        title: const Text("PROTOCOL FORGE",
            style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w900, fontSize: 13)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book, color: Colors.cyanAccent),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CodexPage())),
          ),
        ],
      ),
      body: _controller.protocols.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _controller.protocols.length,
        itemBuilder: (context, i) => _buildProtocolCard(_controller.protocols[i]),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyanAccent,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => _openScriptEditor(null),
      ),
    );
  }

  Widget _buildEmptyState() => const Center(
    child: Text("NO CUSTOM LOGIC DETECTED",
        style: TextStyle(color: Colors.white12, letterSpacing: 2, fontWeight: FontWeight.bold)),
  );

  Widget _buildProtocolCard(CustomProtocol p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        title: Text(p.title.toUpperCase(),
            style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12)),
        subtitle: Text(p.scopeLabel, style: const TextStyle(color: Colors.white24, fontSize: 9)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
          onPressed: () => setState(() => _controller.deleteProtocol(p.id)),
        ),
        onTap: () => _openScriptEditor(p),
      ),
    );
  }

  void _openScriptEditor(CustomProtocol? existing) {
    ProtocolScope selectedScope = existing?.scope ?? ProtocolScope.power;
    final titleCtrl = TextEditingController(text: existing?.title ?? "NEW_SCRIPT");
    final scriptCtrl = TitanSyntaxController(
      text: existing?.script ?? "",
      scope: selectedScope,
      existingProtocolTitles: _controller.protocolTitles,
    );

    List<String> currentErrors = _controller.validate(scriptCtrl.text, selectedScope);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A0A0A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ..._controller.activeTokens.map((t) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.05),
                            foregroundColor: Colors.cyanAccent,
                            padding: EdgeInsets.zero),
                        onPressed: () {
                          final text = scriptCtrl.text;
                          final selection = scriptCtrl.selection;
                          final newText = text.replaceRange(selection.start, selection.end, "$t ");
                          scriptCtrl.value = TextEditingValue(
                              text: newText,
                              selection: TextSelection.collapsed(offset: selection.start + t.length + 1));
                          setModalState(() => currentErrors = _controller.validate(scriptCtrl.text, selectedScope));
                        },
                        child: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  )),
                  IconButton(
                    icon: const Icon(Icons.auto_awesome, color: Colors.orangeAccent, size: 20),
                    onPressed: () => _showTemplatePicker(selectedScope, (template) {
                      setModalState(() {
                        titleCtrl.text = template.title;
                        scriptCtrl.text = template.script;
                        currentErrors = _controller.validate(scriptCtrl.text, selectedScope);
                      });
                    }),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white38, size: 20),
                    onPressed: () => _showTokenConfigurator(setModalState),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(children: [
                Expanded(
                    child: DropdownButton<ProtocolScope>(
                      value: selectedScope,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF111111),
                      items: ProtocolScope.values
                          .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.name.toUpperCase(),
                              style: const TextStyle(color: Colors.orangeAccent, fontSize: 10))))
                          .toList(),
                      onChanged: (val) {
                        setModalState(() {
                          selectedScope = val!;
                          scriptCtrl.scope = val;
                          currentErrors = _controller.validate(scriptCtrl.text, val);
                        });
                      },
                    )),
                const SizedBox(width: 15),
                Expanded(
                    child: TextField(
                        controller: titleCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(hintText: "Protocol Name", border: InputBorder.none))),
              ]),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.05))),
                child: TextField(
                  controller: scriptCtrl,
                  maxLines: 6,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.5, color: Colors.white),
                  onChanged: (v) => setModalState(() => currentErrors = _controller.validate(v, selectedScope)),
                  decoration: const InputDecoration(border: InputBorder.none, hintText: "// Write Logic..."),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                height: 80,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(12)),
                child: currentErrors.isEmpty
                    ? const Text("LOGIC STATUS: OPTIMIZED",
                    style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold))
                    : ListView(
                    children: currentErrors
                        .map((e) => Text("> $e",
                        style: const TextStyle(color: Colors.redAccent, fontSize: 9, fontFamily: 'monospace')))
                        .toList()),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    disabledBackgroundColor: Colors.white10,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                onPressed: currentErrors.isNotEmpty
                    ? null
                    : () {
                  _controller.saveProtocol(existing, titleCtrl.text, scriptCtrl.text, selectedScope);
                  Navigator.pop(ctx);
                  setState(() {});
                },
                child: Text(currentErrors.isEmpty ? "ENGRAVE TO CORE" : "FIX LOGIC ERRORS",
                    style: TextStyle(
                        color: currentErrors.isEmpty ? Colors.black : Colors.white24, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showTemplatePicker(ProtocolScope scope, Function(CustomProtocol) onSelect) {
    final templates = ProtocolLibraryService.getTemplatesByScope(scope);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text("TITAN BLUEPRINT ARCHIVE",
                style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: templates.length,
              itemBuilder: (ctx, i) => ListTile(
                leading: const Icon(Icons.description_outlined, color: Colors.cyanAccent),
                title: Text(templates[i].title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text(ProtocolLibraryService.getTemplateDescription(templates[i].title),
                    style: const TextStyle(color: Colors.white38, fontSize: 10)),
                onTap: () {
                  onSelect(templates[i]);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showTokenConfigurator(StateSetter modalSetState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("PIN COMMANDS", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: _controller.tokenPool.map((t) {
              final bool isActive = _controller.activeTokens.contains(t);
              return GestureDetector(
                onTap: () {
                  setState(() => _controller.toggleTokenPin(t));
                  modalSetState(() {});
                  Navigator.pop(ctx);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isActive ? Colors.cyanAccent : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                      child: Text(t,
                          style: TextStyle(
                              color: isActive ? Colors.black : Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold))),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class TitanSyntaxController extends TextEditingController {
  ProtocolScope scope;
  List<String> existingProtocolTitles;

  TitanSyntaxController({super.text, required this.scope, required this.existingProtocolTitles});

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final List<TextSpan> children = [];
    final pattern = RegExp(r'(\w+\(\w+\)|\w+|[><=]+|[+\-*/.,()]|\s+)');
    final matches = pattern.allMatches(text);

    final keywords = {
      "WHEN", "DO", "OTHERWISE", "STORE", "GLOBAL", "AS", "CALL", "OF", "ALL",
      "SET", "THIS", "WEIGHT", "REPS", "SECONDS", "DISTANCE", "END", "REPEAT", "AND", "OR", "NOT"
    };

    final currentLocalVars = <String>{};
    final asMatches = RegExp(r'AS\s+([A-Z0-9_]+)', caseSensitive: false).allMatches(text);
    for (var m in asMatches) {
      if (m.group(1) != null) currentLocalVars.add(m.group(1)!.toUpperCase());
    }

    final protocolSet = existingProtocolTitles.map((e) => e.toUpperCase()).toSet();

    for (final match in matches) {
      final word = match.group(0)!;
      final upperWord = word.toUpperCase().trim();
      TextStyle wordStyle = const TextStyle(color: Colors.white);

      if (keywords.contains(upperWord) || upperWord == "=?") {
        wordStyle = const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold);
      } else if (double.tryParse(upperWord) != null) {
        wordStyle = const TextStyle(color: Colors.greenAccent);
      } else if (upperWord.startsWith("SET") || upperWord == "ALL") {
        wordStyle = const TextStyle(color: Colors.orangeAccent);
      } else if (currentLocalVars.contains(upperWord) || protocolSet.contains(upperWord)) {
        wordStyle = const TextStyle(color: Colors.cyanAccent);
      } else if (word.trim().isNotEmpty &&
          !["+", "-", "*", "/", ">", "<", "=", ".", ">=", "<=", "=?", ",", "(", ")"].contains(word.trim())) {
        if (TitanEngine.validate("$word . END .", scope, existingProtocolTitles).isNotEmpty) {
          wordStyle = const TextStyle(
              color: Colors.redAccent, decoration: TextDecoration.underline, decorationColor: Colors.redAccent);
        }
      }
      children.add(TextSpan(text: word, style: wordStyle));
    }
    return TextSpan(children: children, style: style);
  }
}