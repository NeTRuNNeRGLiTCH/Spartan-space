import 'package:flutter/material.dart';
import '../models/workout_log.dart';
import '../models/workout_node.dart';
import '../providers/titan_provider.dart';

class HistoryController {
  final TitanProvider provider;

  static const int calendarOrigin = 10000;
  int currentPageIndex = calendarOrigin;
  String? selectedPlanFilter;
  late PageController pageController;

  HistoryController({
    required this.provider,
  }) {
    pageController = PageController(initialPage: currentPageIndex);
  }

  void dispose() {
    pageController.dispose();
  }

  void updatePlanFilter(String? planTitle) {
    selectedPlanFilter = planTitle;
    provider.refreshAll();
  }

  void updatePageIndex(int index) {
    currentPageIndex = index;
    provider.refreshAll();
  }

  List<WorkoutLog> getLogsForDate(DateTime date) {
    return provider.service.getLogsForDay(date);
  }

  DateTime getDateFromIndex(int index) {
    return DateTime.now().add(Duration(days: index - calendarOrigin));
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day && date.month == now.month && date.year == now.year;
  }

  void updateLog(WorkoutLog log, List<WorkoutSet> updatedSets) {
    log.performedSets.clear();
    log.performedSets.addAll(updatedSets);
    provider.saveLog(log);
  }

  void deleteLog(int logId) {
    provider.deleteLog(logId);
  }

  List<String> get planTitles => provider.plans.map((p) => p.title).toList();
}