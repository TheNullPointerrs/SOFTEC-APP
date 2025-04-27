import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskParseService {
  static const String _baseUrl = 'https://softec-backend.onrender.com/parse-task';

  Future<List<TaskEntity>> parseTask(String taskText) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': taskText}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final entities = (jsonData['entities'] as List)
            .map((e) => TaskEntity(
                  text: e['text'],
                  label: e['label'],
                ))
            .toList();
        return entities;
      } else {
        throw Exception('Failed to parse task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error parsing task: $e');
    }
  }
}

class TaskEntity {
  final String text;
  final String label;

  TaskEntity({required this.text, required this.label});
}