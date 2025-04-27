import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softechapp/models/task.dart';
import 'package:softechapp/services/taskService.dart';

class TaskNotifier extends StateNotifier<List<Task>> {
  final TaskService _taskService = TaskService(); // Instance of TaskService

  TaskNotifier() : super([]);

  void addTask(Task task) async {
    state = [...state, task];
    await _taskService.addTask(task); // Add task to Firestore
  }

  void removeTask(String taskId) async {
    state = state.where((task) => task.id != taskId).toList();
    await _taskService.removeTask(taskId); // Remove task from Firestore
  }

  void updateTask(Task updatedTask) async {
    state = [
      for (final task in state)
        if (task.id == updatedTask.id) updatedTask else task
    ];
    await _taskService.updateTask(updatedTask); // Update task in Firestore
  }

  void toggleTaskCompletion(String id) async {
    state = state.map((task) {
      if (task.id == id) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();
    // Update task completion in Firestore
    Task updatedTask = state.firstWhere((task) => task.id == id);
    await _taskService.updateTask(updatedTask);
  }

  List<Task> getTasksByDate(DateTime date) {
    return state.where((task) {
      return task.dueDate.year == date.year &&
          task.dueDate.month == date.month &&
          task.dueDate.day == date.day;
    }).toList();
  }

  List<Task> getOngoingTasks() {
    return state.where((task) => !task.isCompleted).toList();
  }
}

// Create the provider
final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>(
  (ref) => TaskNotifier(),
);
