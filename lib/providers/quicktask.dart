import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softechapp/services/quicktask.dart';

class TaskParseState {
  final bool isLoading;
  final List<TaskEntity>? entities;
  final String? error;

  TaskParseState({
    this.isLoading = false,
    this.entities,
    this.error,
  });

  TaskParseState copyWith({
    bool? isLoading,
    List<TaskEntity>? entities,
    String? error,
  }) {
    return TaskParseState(
      isLoading: isLoading ?? this.isLoading,
      entities: entities ?? this.entities,
      error: error ?? this.error,
    );
  }
}

class TaskParseNotifier extends StateNotifier<TaskParseState> {
  final TaskParseService _service;

  TaskParseNotifier(this._service) : super(TaskParseState());

  Future<void> parseTask(String taskText) async {
    state = state.copyWith(isLoading: true, error: null, entities: null);

    try {
      final entities = await _service.parseTask(taskText);
      state = state.copyWith(isLoading: false, entities: entities);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = TaskParseState();
  }
}

final taskParseProvider = StateNotifierProvider<TaskParseNotifier, TaskParseState>((ref) {
  return TaskParseNotifier(TaskParseService());
});