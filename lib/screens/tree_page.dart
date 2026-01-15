import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_node.dart';
import '../models/custom_protocol.dart';
import '../widgets/planner_widgets.dart';
import '../controllers/tree_controller.dart';
import '../providers/titan_provider.dart';
import 'workout_routine.dart';

class TreePage extends StatefulWidget {
  const TreePage({super.key});

  @override
  _TreePageState createState() => _TreePageState();
}

class _TreePageState extends State<TreePage> {
  late TreeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TreeController(
      provider: context.read<TitanProvider>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TitanProvider>();
    if (provider.plans.isNotEmpty) {
      _controller.currentIndex = _controller.currentIndex.clamp(0, provider.plans.length - 1);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        title: const Text("TITAN ARCHITECT",
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 30, top: 10),
            child: Text("LAUNCH SESSION", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2)),
          ),
          SizedBox(
            height: 200,
            child: provider.plans.isEmpty
                ? const Center(child: Text("NO BLUEPRINTS", style: TextStyle(color: Colors.white38)))
                : PageView.builder(
              controller: _controller.pageController,
              itemCount: provider.plans.length,
              onPageChanged: _controller.updateIndex,
              itemBuilder: (context, index) => _buildBlueprintCarouselCard(index, provider),
            ),
          ),
          const Divider(color: Colors.white24, indent: 30, endIndent: 30),
          Expanded(child: provider.plans.isEmpty ? const SizedBox() : _buildRecursiveEditor(provider)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orangeAccent,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => _showAddRootDialog(),
      ),
    );
  }

  Widget _buildBlueprintCarouselCard(int index, TitanProvider provider) {
    final plan = provider.plans[index];
    final isSelected = index == _controller.currentIndex;
    return PlannerPlanCard(
      title: plan.title,
      isSelected: isSelected,
      isPressing: false,
      onTap: () => _handleModuleLaunch(plan),
      onSettings: () => _showFolderManager(plan, null),
    );
  }

  void _handleModuleLaunch(WorkoutNode plan) {
    final attachedRoadmap = _controller.getRoadmapForPlan(plan);
    final days = plan.children.where((c) => c.type == NodeType.parent).toList();

    Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutRoutine(
      plan: plan,
      roadmap: attachedRoadmap,
      selectedDay: days.isEmpty ? null : days.first,
    )));
  }

  Widget _buildRecursiveEditor(TitanProvider provider) {
    final activePlan = _controller.activePlan;
    if (activePlan == null) return const SizedBox();

    final childrenList = activePlan.children.toList();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: childrenList.length,
      itemBuilder: (context, index) => _buildNode(childrenList[index], activePlan),
    );
  }

  Widget _buildNode(WorkoutNode node, WorkoutNode parent) {
    if (node.type == NodeType.leaf) {
      return PlannerExerciseTile(
        title: node.title,
        subtitle: "${node.sets.length} sets • ${node.protocol.target?.title ?? 'NO SCRIPT'}",
        onEdit: () => _showLeafSettings(node, parent),
      );
    } else {
      final subChildren = node.children.toList();
      return PlannerFolderTile(
        title: node.title,
        onManage: () => _showFolderManager(node, parent),
        children: subChildren.isEmpty
            ? [const Text("Empty", style: TextStyle(color: Colors.white38, fontSize: 11))]
            : subChildren.map((child) => _buildNode(child, node)).toList(),
      );
    }
  }

  void _showRenameDialog(WorkoutNode node, WorkoutNode? parent) {
    final titleCtrl = TextEditingController(text: node.title);
    final setRestCtrl = TextEditingController(text: (node.restTime ?? 90).toString());
    final interRestCtrl = TextEditingController(text: node.interExerciseRest.toString());
    final isRoot = parent == null;

    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: Text(isRoot ? "BLUEPRINT SPECS" : "FOLDER SETTINGS",
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Identification Title")),
        if (isRoot) ...[
          const SizedBox(height: 25),
          const Align(alignment: Alignment.centerLeft, child: Text("GLOBAL RECOVERY CONFIG (S):", style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold))),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: TextField(controller: setRestCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Set Rest"))),
            const SizedBox(width: 15),
            Expanded(child: TextField(controller: interRestCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Transition"))),
          ]),
        ]
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL", style: TextStyle(color: Colors.white24))),
        TextButton(onPressed: () {
          _controller.updateBlueprintSpecs(
              node,
              titleCtrl.text,
              int.tryParse(setRestCtrl.text),
              int.tryParse(interRestCtrl.text),
              isRoot
          );
          Navigator.pop(ctx);
        }, child: const Text("SAVE", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)))
      ],
    ));
  }

  void _showFolderManager(WorkoutNode node, WorkoutNode? parent) {
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF111111), builder: (ctx) => Wrap(children: [
      ListTile(
          leading: const Icon(Icons.edit, color: Colors.orangeAccent),
          title: const Text("Modify Specs"),
          onTap: () {
            Navigator.pop(ctx);
            _showRenameDialog(node, parent);
          }),
      ListTile(leading: const Icon(Icons.add_box, color: Colors.blueAccent), title: const Text("Add Inside"), onTap: () { Navigator.pop(ctx); _showAddDialog(node); }),
      ListTile(leading: const Icon(Icons.delete_forever, color: Colors.redAccent), title: const Text("Delete"), onTap: () { Navigator.pop(ctx); _confirmDelete(node, parent); }),
    ]));
  }

  void _showEditLeafDialog(WorkoutNode node, WorkoutNode parent) {
    final unitLabel = node.trackingType == TrackingType.weightReps ? "R" : (node.trackingType == TrackingType.time ? "SEC" : "METERS");
    final ProtocolScope requiredScope = node.trackingType == TrackingType.weightReps
        ? ProtocolScope.power
        : (node.trackingType == TrackingType.repsOnly ? ProtocolScope.kinetic : (node.trackingType == TrackingType.time ? ProtocolScope.chronos : ProtocolScope.velocity));

    final tempSets = node.sets.map((s) => WorkoutSet(value: s.value, weight: s.weight, isCompleted: s.isCompleted)).toList();
    final filteredProtocols = _controller.provider.service.getAllProtocols().where((p) => p.scopeIndex == requiredScope.index).toList();
    int? selectedProtocolId = node.protocol.target?.id;
    final restCtrl = TextEditingController(text: node.restTime?.toString() ?? "");

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (context, setDialogState) {
      CustomProtocol? currentSelection;
      try { currentSelection = filteredProtocols.firstWhere((p) => p.id == selectedProtocolId); } catch (e) { currentSelection = null; }

      return AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(node.title, style: const TextStyle(color: Colors.orangeAccent)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: restCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Set Recovery (s)", hintText: "Global: ${parent.restTime ?? 90}s"),
            ),
            const SizedBox(height: 20),
            Align(alignment: Alignment.centerLeft, child: Text("ASSIGN ${requiredScope.name.toUpperCase()} SCRIPT:", style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold))),
            DropdownButton<CustomProtocol>(
              value: currentSelection,
              isExpanded: true,
              hint: Text(filteredProtocols.isEmpty ? "No valid scripts found" : "Select Protocol", style: const TextStyle(color: Colors.white24, fontSize: 12)),
              dropdownColor: const Color(0xFF111111),
              items: filteredProtocols.map((p) => DropdownMenuItem<CustomProtocol>(
                  value: p,
                  child: Text(p.title, style: const TextStyle(color: Colors.cyanAccent, fontSize: 12))
              )).toList(),
              onChanged: (val) => setDialogState(() => selectedProtocolId = val?.id),
            ),
            const Divider(height: 40),
            ...tempSets.asMap().entries.map((e) => Row(children: [
              Expanded(child: TextField(decoration: InputDecoration(labelText: unitLabel), controller: TextEditingController(text: e.value.value.toString()), onChanged: (v) => e.value.value = int.tryParse(v) ?? 0)),
              const SizedBox(width: 10),
              if (node.trackingType == TrackingType.weightReps)
                Expanded(child: TextField(decoration: const InputDecoration(labelText: "KG"), controller: TextEditingController(text: e.value.weight.toString()), onChanged: (v) => e.value.weight = double.tryParse(v) ?? 0)),
              IconButton(icon: const Icon(Icons.close, color: Colors.redAccent, size: 16), onPressed: () => setDialogState(() => tempSets.removeAt(e.key))),
            ])),
            TextButton.icon(onPressed: () => setDialogState(() => tempSets.add(WorkoutSet(value: 10, weight: 0))), icon: const Icon(Icons.add, color: Colors.orangeAccent), label: const Text("ADD SET", style: TextStyle(color: Colors.orangeAccent))),
          ])),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL", style: TextStyle(color: Colors.white38))),
          TextButton(onPressed: () {
            CustomProtocol? finalProtocol;
            try { finalProtocol = filteredProtocols.firstWhere((p) => p.id == selectedProtocolId); } catch (e) { finalProtocol = null; }
            _controller.updateLeafNode(node, tempSets, finalProtocol, int.tryParse(restCtrl.text));
            Navigator.pop(ctx);
          }, child: const Text("SAVE", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)))
        ],
      );
    }));
  }

  void _showAddRootDialog() {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text("New Training Module", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: TextField(controller: ctrl, autofocus: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "e.g. Arnold Split")),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL", style: TextStyle(color: Colors.white24))),
        TextButton(onPressed: () {
          if(ctrl.text.isNotEmpty) _controller.addRootBlueprint(ctrl.text);
          Navigator.pop(ctx);
        }, child: const Text("INITIALIZE", style: TextStyle(color: Colors.orangeAccent)))
      ],
    ));
  }

  void _showAddDialog(WorkoutNode targetNode) {
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF111111), builder: (ctx) => Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: const Icon(Icons.create_new_folder), title: const Text("SUB-MODULE"), onTap: () { Navigator.pop(ctx); _showFolderNameDialog(targetNode); }),
      ListTile(leading: const Icon(Icons.fitness_center), title: const Text("EXERCISE"), onTap: () { Navigator.pop(ctx); _showLibraryPicker(targetNode); }),
    ]));
  }

  void _showLibraryPicker(WorkoutNode parent) {
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF111111), isScrollControlled: true, builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.7, expand: false, builder: (context, scrollController) => ListView(
      controller: scrollController,
      children: context.read<TitanProvider>().library.keys.map((muscle) => ExpansionTile(
        title: Text(muscle.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
        children: context.read<TitanProvider>().library[muscle]!.map((libEx) => ListTile(
          title: Text(libEx.name),
          onTap: () {
            Navigator.pop(ctx);
            _controller.addExerciseToFolder(parent, libEx, muscle);
          },
        )).toList(),
      )).toList(),
    ),
    ),
    );
  }

  void _showLeafSettings(WorkoutNode node, WorkoutNode parent) {
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF111111), builder: (ctx) => Wrap(children: [
      ListTile(leading: const Icon(Icons.edit, color: Colors.orangeAccent), title: const Text("Modify Logic"), onTap: () { Navigator.pop(ctx); _showEditLeafDialog(node, parent); }),
      ListTile(leading: const Icon(Icons.delete, color: Colors.redAccent), title: const Text("Remove"), onTap: () { Navigator.pop(ctx); _confirmDelete(node, parent); }),
    ]));
  }

  void _showFolderNameDialog(WorkoutNode parent) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text("Folder Title"),
      content: TextField(controller: ctrl, autofocus: true, style: const TextStyle(color: Colors.white)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL", style: TextStyle(color: Colors.white24))),
        TextButton(onPressed: () {
          if(ctrl.text.isNotEmpty) _controller.addSubFolder(parent, ctrl.text);
          Navigator.pop(ctx);
        }, child: const Text("ADD"))
      ],
    ));
  }

  void _confirmDelete(WorkoutNode node, WorkoutNode? parent) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text("Terminate?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("NO")),
        TextButton(onPressed: () {
          _controller.deleteNode(node, parent);
          Navigator.pop(ctx);
        }, child: const Text("DELETE", style: TextStyle(color: Colors.redAccent))),
      ],
    ));
  }
}