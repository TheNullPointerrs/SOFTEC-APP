import 'package:flutter_riverpod/flutter_riverpod.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String category;
  final bool isCompleted;
  final String? colorCode;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.category,
    this.isCompleted = false,
    this.colorCode,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? category,
    bool? isCompleted,
    String? colorCode,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      colorCode: colorCode ?? this.colorCode,
    );
  }
}

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([
    // Sample tasks for development
    Task(
      id: '1',
      title: 'Watch figma latest video',
      description: 'Learn about new features in Figma',
      dueDate: DateTime.now(),
      category: 'Design',
      colorCode: '#FFAB00',
    ),
    Task(
      id: '2',
      title: 'Complete Flutter project',
      description: 'Finish implementing all features',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      category: 'Development',
      isCompleted: true,
      colorCode: '#FFAB00',
    ),
  ]);

  void addTask(Task task) {
    state = [...state, task];
  }

  void removeTask(String id) {
    state = state.where((task) => task.id != id).toList();
  }

  void updateTask(Task updatedTask) {
    state = state.map((task) {
      if (task.id == updatedTask.id) {
        return updatedTask;
      }
      return task;
    }).toList();
  }

  void toggleTaskCompletion(String id) {
    state = state.map((task) {
      if (task.id == id) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();
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

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
}); 