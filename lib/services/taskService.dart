import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:softechapp/models/task.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final userId = FirebaseAuth.instance.currentUser?.uid;

  // Method to categorize the task
  Future<String> categorizeTask(String taskTitle) async {
    try {
      final response = await http.post(
        Uri.parse('https://softec-backend.onrender.com/categorize-task'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'text': taskTitle,  // Send task title or other necessary data
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return responseBody['category'];  // Return the category from the response
      } else {
        throw Exception('Failed to categorize task');
      }
    } catch (e) {
      print("Error categorizing task: $e");
      throw Exception('Failed to categorize task');
    }
  }

  // Add task to Firestore under the user
  Future<void> addTask(Task task) async {
    try {
      // Categorize the task before adding it
      final category = await categorizeTask(task.title);

      // Set the task category after getting the result from the API
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
        'category': category,  // Set the fetched category here
        'isCompleted': task.isCompleted,
        'colorCode': task.colorCode,
        'parentId': task.parentId,
      });
    } catch (e) {
      print("Error adding task to Firestore: $e");
    }
  }

  // Update task in Firestore under the user
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
        'category': task.category,  // If you have a new category, update it
        'isCompleted': task.isCompleted,
        'colorCode': task.colorCode,
        'parentId': task.parentId,
      });
    } catch (e) {
      print("Error updating task in Firestore: $e");
    }
  }

  // Remove task from Firestore under the user
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
