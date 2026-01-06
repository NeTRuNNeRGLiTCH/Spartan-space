import 'package:flutter/material.dart';

class HistoryPlanFilter extends StatelessWidget {
  final List<String> planTitles;
  final String? selectedPlan;
  final Function(String?) onSelected;

  const HistoryPlanFilter({
    super.key,
    required this.planTitles,
    required this.selectedPlan,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _filterChip("All Logs", null),
          ...planTitles.map((title) => _filterChip(title, title)),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String? value) {
    bool isSelected = selectedPlan == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(color: isSelected ? Colors.black : Colors.white70, fontSize: 12)),
        selected: isSelected,
        selectedColor: Colors.orangeAccent,
        backgroundColor: Colors.white.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (selected) => onSelected(value),
      ),
    );
  }
}

class HistoryLogCard extends StatelessWidget {
  final String title;
  final List<Widget> setRows;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HistoryLogCard({
    super.key,
    required this.title,
    required this.setRows,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF111111),
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.white24), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent), onPressed: onDelete),
          ],
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        children: setRows,
      ),
    );
  }
}