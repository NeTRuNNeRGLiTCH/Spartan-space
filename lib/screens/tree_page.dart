import 'package:flutter/material.dart';
import '../models/workout_node.dart';
import '../models/workout_log.dart';
import '../models/goal_node.dart';
import '../models/custom_protocol.dart';
import '../services/objectbox_service.dart';
import '../widgets/planner_widgets.dart';
import 'workout_routine.dart';

class TreePage extends StatefulWidget {
  final List<WorkoutNode> plans;
  final List<WorkoutLog> logs;
  final List<GoalNode> goals;
  final Map<String, List<LibraryExercise>> library;
  final ObjectBoxService service;
  final VoidCallback onUpdate;

  const TreePage({
    super.key,
    required this.plans,
    required this.logs,
    required this.goals,
    required this.library,
    required this.service,
    required this.onUpdate,
  });

  @override
  _TreePageState createState() => _TreePageState();
}

class _TreePageState extends State<TreePage> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.plans.isNotEmpty) {
      _currentIndex = _currentIndex.clamp(0, widget.plans.length - 1);
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
            child: widget.plans.isEmpty
                ? const Center(child: Text("NO BLUEPRINTS", style: TextStyle(color: Colors.white38)))
                : PageView.builder(
              controller: _pageController,
              itemCount: widget.plans.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) => _buildBlueprintCarouselCard(index),
            ),
          ),
          const Divider(color: Colors.white24, indent: 30, endIndent: 30),
          Expanded(child: widget.plans.isEmpty ? const SizedBox() : _buildRecursiveEditor()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orangeAccent,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => _showAddRootDialog(),
      ),
    );
  }

  Widget _buildBlueprintCarouselCard(int index) {
    var plan = widget.plans[index];
    bool isSelected = index == _currentIndex;
    return PlannerPlanCard(
      title: plan.title,
      isSelected: isSelected,
      isPressing: false,
      onTap: () => _handleModuleLaunch(plan),
      // --- IDENTIFICATION: Roots pass NULL as parent ---
      onSettings: () => _showFolderManager(plan, null),
    );
  }

  void _handleModuleLaunch(WorkoutNode plan) {
    GoalNode? attachedRoadmap;
    try {
      attachedRoadmap = widget.goals.firstWhere((g) => g.title == plan.title);
    } catch (e) { attachedRoadmap = null; }

    List<WorkoutNode> days = plan.children.where((c) => c.type == NodeType.parent).toList();
    Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutRoutine(
      plan: plan, roadmap: attachedRoadmap, selectedDay: days.isEmpty ? null : days.first,
      logs: widget.logs, service: widget.service, onUpdate: widget.onUpdate,
    )));
  }

  Widget _buildRecursiveEditor() {
    var activePlan = widget.plans[_currentIndex];
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
        // --- IDENTIFICATION: Folders pass their ACTUAL parent ---
        onManage: () => _showFolderManager(node, parent),
        children: subChildren.isEmpty
            ? [const Text("Empty", style: TextStyle(color: Colors.white38, fontSize: 11))]
            : subChildren.map((child) => _buildNode(child, node)).toList(),
      );
    }
  }

  void _showRenameDialog(WorkoutNode node, WorkoutNode? parent) {
    TextEditingController titleCtrl = TextEditingController(text: node.title);
    TextEditingController setRestCtrl = TextEditingController(text: (node.restTime ?? 90).toString());
    TextEditingController interRestCtrl = TextEditingController(text: node.interExerciseRest.toString());

    // --- LOGIC: If parent is null, this is the Master Blueprint ---
    bool isRootBlueprint = parent == null;

    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: Text(isRootBlueprint ? "BLUEPRINT SPECS" : "FOLDER SETTINGS",
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Identification Title")),

        // --- ENFORCEMENT: Rest vars only visible/editable at the ROOT level ---
        if (isRootBlueprint) ...[
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
          node.title = titleCtrl.text;

          if (isRootBlueprint) {
            node.restTime = int.tryParse(setRestCtrl.text) ?? 90;
            node.interExerciseRest = int.tryParse(interRestCtrl.text) ?? 180;
            node.isRoot = true; // Ensure flag is set
          } else {
            node.restTime = null; // Subfolders cannot hold rest values
            node.isRoot = false; // Ensure flag is cleared
          }

          widget.service.savePlan(node);
          widget.onUpdate();
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
    String unitLabel = "R";
    ProtocolScope requiredScope = ProtocolScope.power;

    switch (node.trackingType) {
      case TrackingType.weightReps: unitLabel = "R"; requiredScope = ProtocolScope.power; break;
      case TrackingType.repsOnly: unitLabel = "R"; requiredScope = ProtocolScope.kinetic; break;
      case TrackingType.time: unitLabel = "SEC"; requiredScope = ProtocolScope.chronos; break;
      case TrackingType.distance: unitLabel = "METERS"; requiredScope = ProtocolScope.velocity; break;
    }

    List<WorkoutSet> tempSets = node.sets.map((s) =>
        WorkoutSet(value: s.value, weight: s.weight, isCompleted: s.isCompleted)).toList();

    List<CustomProtocol> filteredProtocols = widget.service.getAllProtocols()
        .where((p) => p.scopeIndex == requiredScope.index).toList();

    int? selectedProtocolId = node.protocol.target?.id;

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
              controller: TextEditingController(text: node.restTime?.toString() ?? ""),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Set Recovery (s)", hintText: "Global: ${parent.restTime ?? 90}s"),
              onChanged: (v) => node.restTime = int.tryParse(v),
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
            node.sets.clear(); node.sets.addAll(tempSets);
            if (selectedProtocolId != null) { node.protocol.target = filteredProtocols.firstWhere((p) => p.id == selectedProtocolId); } else { node.protocol.target = null; }
            widget.service.savePlan(node); widget.onUpdate(); Navigator.pop(ctx);
          }, child: const Text("SAVE", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)))
        ],
      );
    }));
  }

  void _showAddRootDialog() {
    TextEditingController ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text("New Training Module", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: TextField(controller: ctrl, autofocus: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "e.g. Arnold Split")),
      actions: [TextButton(onPressed: () {
        if(ctrl.text.isNotEmpty) {
          // --- MARK AS ROOT BLUEPRINT ---
          final newNode = WorkoutNode(title: ctrl.text, typeIndex: NodeType.parent.index, isRoot: true, restTime: 90, interExerciseRest: 180);
          widget.service.savePlan(newNode);
          widget.onUpdate();
        }
        Navigator.pop(ctx);
      }, child: const Text("INITIALIZE", style: TextStyle(color: Colors.orangeAccent)))],
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
      children: widget.library.keys.map((muscle) => ExpansionTile(
        title: Text(muscle.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
        children: widget.library[muscle]!.map((libEx) => ListTile(
          title: Text(libEx.name),
          onTap: () {
            Navigator.pop(ctx);
            final newNode = WorkoutNode(title: libEx.name, typeIndex: NodeType.leaf.index, trackingIndex: libEx.trackingType.index, muscleGroup: muscle);
            newNode.sets.add(WorkoutSet(value: 10, weight: 0));
            parent.children.add(newNode);
            widget.service.savePlan(parent);
            widget.onUpdate();
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
    TextEditingController ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text("Folder Title"),
      content: TextField(controller: ctrl, autofocus: true, style: const TextStyle(color: Colors.white)),
      actions: [TextButton(onPressed: () {
        if(ctrl.text.isNotEmpty) {
          // --- MARK AS SUB-FOLDER (Not a Root) ---
          parent.children.add(WorkoutNode(title: ctrl.text, typeIndex: NodeType.parent.index, isRoot: false));
          widget.service.savePlan(parent);
          widget.onUpdate();
        }
        Navigator.pop(ctx);
      }, child: const Text("ADD"))],
    ));
  }

  void _confirmDelete(WorkoutNode node, WorkoutNode? parent) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text("Terminate?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("NO")),
        TextButton(onPressed: () {
          if (parent != null) { parent.children.remove(node); widget.service.savePlan(parent); }
          else { widget.service.deletePlan(node.id); }
          widget.onUpdate(); Navigator.pop(ctx);
        }, child: const Text("DELETE", style: TextStyle(color: Colors.redAccent))),
      ],
    ));
  }
}