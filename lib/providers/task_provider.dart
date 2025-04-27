import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softechapp/models/task.dart';
import 'package:softechapp/services/taskService.dart';

class TaskNotifier extends StateNotifier<List<Task>> {
  final TaskService _taskService = TaskService();

  TaskNotifier() : super([]) {
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      final tasks = await _taskService.getTasks();
      state = tasks;
    } catch (e) {
      print("Error fetching tasks: $e");
    }
  }

  Future<void> addTask(Task task) async {
    state = [...state, task];
    await _taskService.addTask(task);
  }

  Future<void> removeTask(String taskId) async {
    state = state.where((task) => task.id != taskId).toList();
    await _taskService.removeTask(taskId);
  }

  Future<void> updateTask(Task updatedTask) async {
    state = [
      for (final task in state)
        if (task.id == updatedTask.id) updatedTask else task
    ];
    await _taskService.updateTask(updatedTask);
  }

  Future<void> toggleTaskCompletion(String id) async {
    state = state.map((task) {
      if (task.id == id) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();
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

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>(
  (ref) => TaskNotifier(),
);