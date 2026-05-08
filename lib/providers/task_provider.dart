import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  List<KairoTask> _tasks = [];
  final String _storageKey = 'kairo_tasks';

  List<KairoTask> get tasks => _tasks;
  List<KairoTask> get activeTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<KairoTask> get priorityTasks => _tasks.where((t) => !t.isCompleted && t.isPriority).toList();

  TaskProvider() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString(_storageKey);
    if (tasksJson != null) {
      final List<dynamic> decoded = jsonDecode(tasksJson);
      _tasks = decoded.map((item) => KairoTask(
        id: item['id'],
        title: item['title'],
        isCompleted: item['isCompleted'] ?? false,
        isPriority: item['isPriority'] ?? false,
        createdAt: DateTime.parse(item['createdAt']),
        source: item['source'] ?? '',
      )).toList();
      notifyListeners();
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_tasks.map((t) => {
      'id': t.id,
      'title': t.title,
      'isCompleted': t.isCompleted,
      'isPriority': t.isPriority,
      'createdAt': t.createdAt.toIso8601String(),
      'source': t.source,
    }).toList());
    await prefs.setString(_storageKey, encoded);
  }

  void addTask(KairoTask task) {
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
      _saveTasks();
      notifyListeners();
    }
  }

  // Logic to parse summary and create tasks
  void generateTasksFromSummary(String summary, String sourceTitle) {
    // In a real app, this would use an LLM or regex to find action items
    // For now, we simulate finding a few action items
    if (summary.contains("ACTION ITEMS:")) {
      final taskTitle = "Follow up on $sourceTitle action items";
      addTask(KairoTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: taskTitle,
        createdAt: DateTime.now(),
        source: sourceTitle,
      ));
    }
  }
}
