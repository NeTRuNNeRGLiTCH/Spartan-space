import 'package:flutter/material.dart';
import '../models/goal_node.dart';
import '../models/workout_node.dart';
import '../services/objectbox_service.dart';
import '../widgets/expected_widgets.dart';

class ExpectedProgressPage extends StatefulWidget {
  final List<GoalNode> goals;
  final List<WorkoutNode> plans;
  final ObjectBoxService service;
  final VoidCallback onUpdate;

  const ExpectedProgressPage({
    super.key,
    required this.goals,
    required this.plans,
    required this.service,
    required this.onUpdate,
  });

  @override
  State<ExpectedProgressPage> createState() => _ExpectedProgressPageState();
}

class _ExpectedProgressPageState extends State<ExpectedProgressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        title: const Text("STRENGTH ROADMAPS",
            style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: widget.goals.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: widget.goals.length,
        itemBuilder: (context, index) => _buildRecursiveGoal(widget.goals[index], widget.goals),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        onPressed: () => _showFolderPicker(context),
        icon: const Icon(Icons.add_link, color: Colors.white),
        label: const Text("ATTACH ROADMAP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.track_changes_rounded, color: Colors.white.withOpacity(0.05), size: 80),
          const SizedBox(height: 20),
          const Text("NO ROADMAPS ACTIVE", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold)),
          const Text("Attach a roadmap to an existing plan.", style: TextStyle(color: Colors.white10, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildRecursiveGoal(GoalNode node, List<GoalNode> parentList) {
    if (node.type == GoalNodeType.exercise) {
      return GoalExerciseTile(
        title: node.title,
        nextWeight: node.nextTargetWeight,
        onEdit: () => _showEditExerciseGoal(node),
      );
    } else {
      final childrenList = node.children.toList();
      return GoalFolderTile(
        title: node.title,
        current: node.completedSessions,
        total: node.totalSessions,
        onManage: () => _showParentManager(node, parentList),
        children: childrenList.isEmpty
            ? [const Center(child: Text("No linked exercises", style: TextStyle(color: Colors.white10, fontSize: 11)))]
            : childrenList.map((child) => _buildRecursiveGoal(child, childrenList)).toList(),
      );
    }
  }

  void _showFolderPicker(BuildContext context) {
    if (widget.plans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("No Blueprints Found. Create one in 'PLAN' first."),
      ));
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("LINK GOAL TO PLAN:", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.plans.length,
              itemBuilder: (ctx, i) => ListTile(
                leading: const Icon(Icons.architecture, color: Colors.orangeAccent),
                title: Text(widget.plans[i].title, style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  _setupRoadmapDetails(widget.plans[i]);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _setupRoadmapDetails(WorkoutNode source) {
    TextEditingController sessionCtrl = TextEditingController(text: "10");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text("Link: ${source.title}"),
        content: TextField(
          controller: sessionCtrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Roadmap Duration (Sessions)"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () {
              int totalS = int.tryParse(sessionCtrl.text) ?? 10;

              GoalNode newRoadmap = GoalNode(
                title: source.title,
                typeIndex: GoalNodeType.folder.index,
                totalSessions: totalS,
              );

              _cloneStructure(source, newRoadmap);

              widget.service.saveGoal(newRoadmap);
              widget.onUpdate();
              Navigator.pop(ctx);
            },
            child: const Text("CREATE"),
          ),
        ],
      ),
    );
  }

  void _cloneStructure(WorkoutNode source, GoalNode target) {
    for (var child in source.children.toList()) {
      if (child.type == NodeType.leaf) {
        final sets = child.sets.toList();
        double startWeight = sets.isNotEmpty ? sets.first.weight : 0;

        target.children.add(GoalNode(
          title: child.title,
          typeIndex: GoalNodeType.exercise.index,
          currentWeight: startWeight,
          targetWeight: startWeight + 10,
          weightStep: 5.0,
        ));
      } else {
        GoalNode sub = GoalNode(title: child.title, typeIndex: GoalNodeType.folder.index);
        target.children.add(sub);
        _cloneStructure(child, sub);
      }
    }
  }

  void _showParentManager(GoalNode node, List<GoalNode> parentList) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Wrap(children: [
        ListTile(
          leading: const Icon(Icons.fast_forward, color: Colors.greenAccent),
          title: const Text("Manually Advance Session"),
          onTap: () {
            if (node.completedSessions < node.totalSessions) {
              node.completedSessions++;
              widget.service.saveGoal(node);
              widget.onUpdate();
            }
            Navigator.pop(ctx);
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings_backup_restore, color: Colors.white38),
          title: const Text("Reset Roadmap Progress"),
          onTap: () {
            node.completedSessions = 0;
            widget.service.saveGoal(node);
            widget.onUpdate();
            Navigator.pop(ctx);
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_sweep, color: Colors.redAccent),
          title: const Text("Delete Roadmap"),
          onTap: () {
            widget.service.goalBox.remove(node.id);
            widget.onUpdate();
            Navigator.pop(ctx);
          },
        ),
      ]),
    );
  }

  void _showEditExerciseGoal(GoalNode node) {
    TextEditingController c1 = TextEditingController(text: node.currentWeight.toString());
    TextEditingController c2 = TextEditingController(text: node.targetWeight.toString());
    TextEditingController c3 = TextEditingController(text: node.weightStep.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text("Goal: ${node.title}"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: c1, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Starting Weight (kg)")),
              TextField(controller: c2, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Final Goal (kg)")),
              TextField(controller: c3, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Plate Step (e.g., 5.0)")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          TextButton(
            onPressed: () {
              node.currentWeight = double.tryParse(c1.text) ?? 0;
              node.targetWeight = double.tryParse(c2.text) ?? 0;
              node.weightStep = double.tryParse(c3.text) ?? 2.5;

              widget.service.saveGoal(node);
              widget.onUpdate();
              Navigator.pop(ctx);
            },
            child: const Text("SAVE", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}