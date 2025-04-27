import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/task_service.dart';

final taskServiceProvider = Provider<TaskService>((ref) => TaskService());

// Provider that fetches task counts
final taskCountProvider = FutureProvider.family<Map<String, int>, String>((ref, uid) async {
  final service = ref.read(taskServiceProvider);
  return service.fetchTaskCounts(uid);
});