import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal_node.dart';
import '../models/workout_node.dart';
import '../widgets/expected_widgets.dart';
import '../controllers/expected_progress_controller.dart';
import '../providers/titan_provider.dart';

class ExpectedProgressPage extends StatefulWidget {
  const ExpectedProgressPage({super.key});

  @override
  State<ExpectedProgressPage> createState() => _ExpectedProgressPageState();
}

class _ExpectedProgressPageState extends State<ExpectedProgressPage> {
  late ExpectedProgressController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExpectedProgressController(
      provider: context.read<TitanProvider>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TitanProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        title: const Text("STRENGTH ROADMAPS",
            style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: provider.goals.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: provider.goals.length,
        itemBuilder: (context, index) => _buildRecursiveGoal(provider.goals[index], provider.goals),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        onPressed: () => _showFolderPicker(context, provider),
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
    return node.type == GoalNodeType.exercise
        ? GoalExerciseTile(
      title: node.title,
      nextWeight: node.nextTargetWeight,
      onEdit: () => _showEditExerciseGoal(node),
    )
        : GoalFolderTile(
      title: node.title,
      current: node.completedSessions,
      total: node.totalSessions,
      onManage: () => _showParentManager(node, parentList),
      children: node.children.isEmpty
          ? [const Center(child: Text("No linked exercises", style: TextStyle(color: Colors.white10, fontSize: 11)))]
          : node.children.map((child) => _buildRecursiveGoal(child, node.children.toList())).toList(),
    );
  }

  void _showFolderPicker(BuildContext context, TitanProvider provider) {
    if (provider.plans.isEmpty) {
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
              itemCount: provider.plans.length,
              itemBuilder: (ctx, i) => ListTile(
                leading: const Icon(Icons.architecture, color: Colors.orangeAccent),
                title: Text(provider.plans[i].title, style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  _setupRoadmapDetails(provider.plans[i]);
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
    final sessionCtrl = TextEditingController(text: "10");

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
              final totalS = int.tryParse(sessionCtrl.text) ?? 10;
              _controller.linkRoadmapToPlan(source, totalS);
              Navigator.pop(ctx);
            },
            child: const Text("CREATE"),
          ),
        ],
      ),
    );
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
            _controller.advanceSession(node);
            Navigator.pop(ctx);
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings_backup_restore, color: Colors.white38),
          title: const Text("Reset Roadmap Progress"),
          onTap: () {
            _controller.resetProgress(node);
            Navigator.pop(ctx);
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_sweep, color: Colors.redAccent),
          title: const Text("Delete Roadmap"),
          onTap: () {
            _controller.deleteRoadmap(node.id);
            Navigator.pop(ctx);
          },
        ),
      ]),
    );
  }

  void _showEditExerciseGoal(GoalNode node) {
    final c1 = TextEditingController(text: node.currentWeight.toString());
    final c2 = TextEditingController(text: node.targetWeight.toString());
    final c3 = TextEditingController(text: node.weightStep.toString());

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
              final current = double.tryParse(c1.text) ?? 0;
              final target = double.tryParse(c2.text) ?? 0;
              final step = double.tryParse(c3.text) ?? 2.5;
              _controller.updateExerciseGoal(node, current, target, step);
              Navigator.pop(ctx);
            },
            child: const Text("SAVE", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}