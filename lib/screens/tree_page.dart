import 'package:flutter/material.dart';
import '../models/workout_node.dart';
import '../models/workout_log.dart';
import '../models/goal_node.dart';
import '../widgets/planner_widgets.dart';
import 'workout_routine.dart';

class TreePage extends StatefulWidget {
  final List<WorkoutNode> plans;
  final List<WorkoutLog> logs;
  final List<GoalNode> goals;
  final Map<String, List<LibraryExercise>> library;
  final VoidCallback onUpdate;

  const TreePage({
    super.key,
    required this.plans,
    required this.logs,
    required this.goals,
    required this.library,
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.plans.isNotEmpty) {
      _currentIndex = _currentIndex.clamp(0, widget.plans.length - 1);
    } else {
      _currentIndex = 0;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        title: const Text("TITAN ARCHITECT",
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 30, top: 10, bottom: 5),
            child: Text("LAUNCH SESSION",
                style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            child: Divider(color: Colors.white24),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 30, bottom: 15),
            child: Text("MANAGE MODULE STRUCTURE",
                style: TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ),
          Expanded(
            child: widget.plans.isEmpty
                ? const Center(child: Text("Create a Blueprint to start.", style: TextStyle(color: Colors.white38)))
                : _buildRecursiveEditor(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orangeAccent,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => _showAddRootDialog(),
      ),
    );
  }

  void _handleModuleLaunch(WorkoutNode plan) {
    GoalNode? attachedRoadmap;
    try {
      attachedRoadmap = widget.goals.firstWhere((g) => g.title == plan.title);
    } catch (e) {
      attachedRoadmap = null;
    }
    List<WorkoutNode> days = plan.children.where((c) => c.type == NodeType.parent).toList();
    if (days.isEmpty) {
      _launch(plan, attachedRoadmap, null);
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF111111),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        builder: (ctx) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("WHICH SESSION TODAY?", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
            ...days.map((day) => ListTile(
              leading: const Icon(Icons.calendar_today_rounded, color: Colors.white54, size: 18),
              title: Text(day.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _launch(plan, attachedRoadmap, day);
              },
            )).toList(),
            const SizedBox(height: 20),
          ],
        ),
      );
    }
  }

  void _launch(WorkoutNode plan, GoalNode? roadmap, WorkoutNode? selectedDay) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutRoutine(
          plan: plan,
          roadmap: roadmap,
          selectedDay: selectedDay,
          logs: widget.logs,
          onUpdate: widget.onUpdate,
          onLog: (newLog) {
            setState(() => widget.logs.insert(0, newLog));
            widget.onUpdate();
          },
        ),
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
      onSettings: () => _showFolderManager(plan, widget.plans),
    );
  }

  Widget _buildRecursiveEditor() {
    var activePlan = widget.plans[_currentIndex];
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: activePlan.children.length,
      itemBuilder: (context, index) {
        return _buildNode(activePlan.children[index], activePlan.children);
      },
    );
  }

  Widget _buildNode(WorkoutNode node, List<WorkoutNode> parentList) {
    if (node.type == NodeType.leaf) {
      int displayRest = node.restTime ?? widget.plans[_currentIndex].restTime ?? 90;
      return PlannerExerciseTile(
        title: node.title,
        subtitle: "${node.sets.length} sets • ${displayRest}s Recovery • ${node.muscleGroup ?? 'GEN'}",
        onEdit: () => _showLeafSettings(node, parentList),
      );
    } else {
      return PlannerFolderTile(
        title: node.title,
        onManage: () => _showFolderManager(node, parentList),
        children: node.children.isEmpty
            ? [const Text("Empty", style: TextStyle(color: Colors.white38, fontSize: 11))]
            : node.children.map((child) => _buildNode(child, node.children)).toList(),
      );
    }
  }

  void _showAddDialog(List<WorkoutNode> targetList) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.create_new_folder, color: Colors.blueAccent),
            title: const Text("NEW SUB-MODULE", style: TextStyle(color: Colors.white)),
            onTap: () { Navigator.pop(ctx); _showFolderNameDialog(targetList); },
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center, color: Colors.orangeAccent),
            title: const Text("CHOOSE EXERCISE", style: TextStyle(color: Colors.white)),
            onTap: () { Navigator.pop(ctx); _showLibraryPicker(targetList); },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showLibraryPicker(List<WorkoutNode> targetList) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          children: widget.library.keys.map((muscle) => ExpansionTile(
            title: Text(muscle.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
            children: widget.library[muscle]!.map((libEx) => ListTile(
              title: Text(libEx.name, style: const TextStyle(color: Colors.white)),
              subtitle: Text(libEx.trackingType.name.toUpperCase(), style: const TextStyle(fontSize: 9, color: Colors.white54)),
              onTap: () {
                Navigator.pop(ctx);
                WorkoutNode newNode = WorkoutNode(
                    title: libEx.name,
                    type: NodeType.leaf,
                    trackingType: libEx.trackingType,
                    muscleGroup: muscle,
                    restTime: null,
                    sets: [WorkoutSet(value: 0, weight: 0)]
                );
                _showEditLeafDialog(newNode, isNew: true, onSaved: () {
                  setState(() => targetList.add(newNode));
                  widget.onUpdate();
                });
              },
            )).toList(),
          )).toList(),
        ),
      ),
    );
  }

  void _showEditLeafDialog(WorkoutNode node, {bool isNew = false, VoidCallback? onSaved}) {
    List<WorkoutSet> tempSets = List.from(node.sets);
    int rootRest = widget.plans[_currentIndex].restTime ?? 90;
    TextEditingController localRestCtrl = TextEditingController(text: node.restTime?.toString() ?? "");

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: Text(node.title, style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
      content: SizedBox(width: double.maxFinite, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Custom Intra-Set Recovery (s)",
              labelStyle: const TextStyle(color: Colors.white70),
              hintText: "Using Global: ${rootRest}s",
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.shutter_speed, size: 18, color: Colors.white54),
            ),
            controller: localRestCtrl),
        const Divider(height: 30, color: Colors.white24),
        ...tempSets.asMap().entries.map((entry) => Row(children: [
          Expanded(child: TextField(
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  labelText: node.trackingType == TrackingType.time ? "Seconds" : "Reps",
                  labelStyle: const TextStyle(color: Colors.white54)),
              controller: TextEditingController(text: entry.value.value.toString()),
              onChanged: (v) => entry.value.value = int.tryParse(v) ?? 0)),
          const SizedBox(width: 10),
          if(node.trackingType == TrackingType.weightReps)
            Expanded(child: TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: "kg",
                    labelStyle: TextStyle(color: Colors.white54)),
                controller: TextEditingController(text: entry.value.weight.toString()),
                onChanged: (v) => entry.value.weight = double.tryParse(v) ?? 0)),
          IconButton(icon: const Icon(Icons.close, color: Colors.redAccent, size: 16), onPressed: () => setDialogState(() => tempSets.removeAt(entry.key))),
        ])),
        TextButton.icon(onPressed: () => setDialogState(() => tempSets.add(WorkoutSet(value: 0, weight: 0))), icon: const Icon(Icons.add, color: Colors.cyanAccent), label: const Text("ADD SET", style: TextStyle(color: Colors.cyanAccent))),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL", style: TextStyle(color: Colors.white54))),
        ElevatedButton(onPressed: () {
          setState(() {
            node.sets = tempSets;
            node.restTime = int.tryParse(localRestCtrl.text);
          });
          if (isNew && onSaved != null) onSaved();
          widget.onUpdate();
          Navigator.pop(ctx);
        }, child: const Text("SAVE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      ],
    )));
  }

  void _showAddRootDialog() {
    TextEditingController ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text("New Training Module", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: TextField(controller: ctrl, autofocus: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "e.g. Arnold Split", hintStyle: TextStyle(color: Colors.white38))),
      actions: [TextButton(onPressed: () {
        if(ctrl.text.isNotEmpty) setState(() => widget.plans.add(WorkoutNode(title: ctrl.text, type: NodeType.parent, restTime: 90, interExerciseRest: 180)));
        widget.onUpdate(); Navigator.pop(ctx);
      }, child: const Text("INITIALIZE", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)))],
    ));
  }

  void _showFolderNameDialog(List<WorkoutNode> targetList) {
    TextEditingController ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text("Sub-Module Title", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: TextField(controller: ctrl, autofocus: true, style: const TextStyle(color: Colors.white)),
      actions: [TextButton(onPressed: () {
        if(ctrl.text.isNotEmpty) setState(() => targetList.add(WorkoutNode(title: ctrl.text, type: NodeType.parent)));
        widget.onUpdate(); Navigator.pop(ctx);
      }, child: const Text("ADD", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)))],
    ));
  }

  void _showFolderManager(WorkoutNode node, List<WorkoutNode> parentList) {
    bool isRoot = widget.plans.contains(node);
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF111111), builder: (ctx) => Wrap(children: [
      ListTile(
          leading: const Icon(Icons.edit, color: Colors.orangeAccent),
          title: Text(isRoot ? "Rename / Global Protocol" : "Rename", style: const TextStyle(color: Colors.white)),
          onTap: () { Navigator.pop(ctx); _showRenameDialog(node, isRoot); }),
      ListTile(leading: const Icon(Icons.add_box, color: Colors.blueAccent), title: const Text("Add Inside", style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(ctx); _showAddDialog(node.children); }),
      ListTile(leading: const Icon(Icons.delete_forever, color: Colors.redAccent), title: const Text("Delete", style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(ctx); _confirmDelete(node, parentList); }),
    ]));
  }

  void _showLeafSettings(WorkoutNode node, List<WorkoutNode> parentList) {
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF111111), builder: (ctx) => Wrap(children: [
      ListTile(leading: const Icon(Icons.edit, color: Colors.orangeAccent), title: const Text("Modify Set Targets", style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(ctx); _showEditLeafDialog(node); }),
      ListTile(leading: const Icon(Icons.delete, color: Colors.redAccent), title: const Text("Remove", style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(ctx); _confirmDelete(node, parentList); }),
    ]));
  }

  void _showRenameDialog(WorkoutNode node, bool isRoot) {
    TextEditingController titleCtrl = TextEditingController(text: node.title);
    TextEditingController globalRestCtrl = TextEditingController(text: node.restTime?.toString() ?? "90");
    TextEditingController transRestCtrl = TextEditingController(text: node.interExerciseRest.toString());

    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text("Sync Data", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: titleCtrl, autofocus: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Identification Title", labelStyle: TextStyle(color: Colors.white70))),
        if (isRoot) ...[
          const SizedBox(height: 20),
          const Align(alignment: Alignment.centerLeft, child: Text("PLAN-WIDE PROTOCOLS (S)", style: TextStyle(color: Colors.white54, fontSize: 8, fontWeight: FontWeight.bold))),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: TextField(controller: globalRestCtrl, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Standard Recovery", labelStyle: TextStyle(fontSize: 10, color: Colors.white38)))),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: transRestCtrl, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Module Transition", labelStyle: TextStyle(fontSize: 10, color: Colors.white38)))),
          ]),
        ]
      ]),
      actions: [
        TextButton(onPressed: () {
          setState(() {
            node.title = titleCtrl.text;
            if (isRoot) {
              node.restTime = int.tryParse(globalRestCtrl.text) ?? 90;
              node.interExerciseRest = int.tryParse(transRestCtrl.text) ?? 180;
            }
          });
          widget.onUpdate(); Navigator.pop(ctx);
        }, child: const Text("SAVE", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)))
      ],
    ));
  }

  void _confirmDelete(WorkoutNode node, List<WorkoutNode> parentList) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text("Terminate?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("NO", style: TextStyle(color: Colors.white54))),
            TextButton(onPressed: () { setState(() => parentList.remove(node)); widget.onUpdate(); Navigator.pop(ctx); }, child: const Text("DELETE", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
          ],
        ));
  }

  Widget _buildEmptyBlueprintHint() => const Center(child: Text("Tap + to build your first Training Module", style: TextStyle(color: Colors.white38, fontSize: 12)));
}