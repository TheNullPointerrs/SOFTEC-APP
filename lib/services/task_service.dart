import 'package:cloud_firestore/cloud_firestore.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, int>> fetchTaskCounts(String uid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: uid)
          .get();

      int totalTasks = querySnapshot.docs.length;
      int tasksCompleted = querySnapshot.docs.where((doc) => doc['isCompleted'] == true).length;

      return {
        'totalTasks': totalTasks,
        'tasksCompleted': tasksCompleted,
      };
    } catch (e) {
      print('Error fetching task counts: $e');
      return {
        'totalTasks': 0,
        'tasksCompleted': 0,
      };
    }
  }
}