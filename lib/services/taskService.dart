import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:softechapp/models/task.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final userId = FirebaseAuth.instance.currentUser?.uid;

  Future<List<Task>> getTasks() async {
    try {
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Task(
          id: data['id'],
          title: data['title'],
          description: data['description'] ?? '',
          dueDate: DateTime.parse(data['dueDate']),
          category: data['category'] ?? 'General',
          isCompleted: data['isCompleted'] ?? false,
          colorCode: data['colorCode'] ?? '#FFAB00',
          parentId: data['parentId'],
        );
      }).toList();
    } catch (e) {
      print("Error fetching tasks from Firestore: $e");
      return [];
    }
  }

  Future<String> categorizeTask(String taskTitle) async {
    try {
      final response = await http.post(
        Uri.parse('https://softec-backend.onrender.com/categorize-task'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'text': taskTitle,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return responseBody['category'];
      } else {
        throw Exception('Failed to categorize task');
      }
    } catch (e) {
      print("Error categorizing task: $e");
      return 'General';
    }
  }

  Future<void> addTask(Task task) async {
    try {
      final category = await categorizeTask(task.title);
      final taskRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(task.id);

      await taskRef.set({
        'id': task.id,
        'title': task.title,
        'description': task.description,
        'dueDate': task.dueDate.toIso8601String(),
        'category': category,
        'isCompleted': task.isCompleted,
        'colorCode': task.colorCode,
        'parentId': task.parentId,
      });
    } catch (e) {
      print("Error adding task to Firestore: $e");
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final taskRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(task.id);

      await taskRef.update({
        'title': task.title,
        'description': task.description,
        'dueDate': task.dueDate.toIso8601String(),
        'category': task.category,
        'isCompleted': task.isCompleted,
        'colorCode': task.colorCode,
        'parentId': task.parentId,
      });
    } catch (e) {
      print("Error updating task in Firestore: $e");
    }
  }

  Future<void> removeTask(String taskId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } catch (e) {
      print("Error removing task from Firestore: $e");
    }
  }
}