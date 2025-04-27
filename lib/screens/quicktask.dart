import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:softechapp/models/task.dart';
import 'package:softechapp/providers/quicktask.dart';
import 'package:softechapp/providers/task_provider.dart';
import '../const/theme.dart';
import '../utils/date_time_parser.dart'; // Import the new utility

class QuickTaskScreen extends ConsumerStatefulWidget {
  const QuickTaskScreen({Key? key}) : super(key: key);

  @override
  _QuickTaskScreenState createState() => _QuickTaskScreenState();
}

class _QuickTaskScreenState extends ConsumerState<QuickTaskScreen> {
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final parseState = ref.watch(taskParseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Task'),
        backgroundColor: AppTheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                labelText: 'Enter task (e.g., Submit assignment by tomorrow 5pm)',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isDarkMode ? Colors.black12 : Colors.grey.shade100,
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  ref.read(taskParseProvider.notifier).parseTask(value);
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final taskText = _taskController.text.trim();
                if (taskText.isNotEmpty) {
                  ref.read(taskParseProvider.notifier).parseTask(taskText);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a task'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Parse Task'),
            ),
            const SizedBox(height: 20),
            if (parseState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (parseState.error != null)
              Text(
                'Error: ${parseState.error}',
                style: const TextStyle(color: Colors.red),
              )
            else if (parseState.entities != null) ...[
              const Text(
                'Parsed Task Details:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...parseState.entities!.map((entity) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      '${entity.label}: ${entity.text}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final entities = parseState.entities!;
                  String? title;
                  String? dateText;
                  String? timeText;
                  String category = 'General';

                  // Extract title, date, and time from entities
                  for (var entity in entities) {
                    if (entity.label == 'TITLE') {
                      title = entity.text;
                    } else if (entity.label == 'DATE') {
                      dateText = entity.text;
                    } else if (entity.label == 'TIME') {
                      timeText = entity.text;
                    }
                  }

                  if (title != null && title.isNotEmpty) {
                    // Parse date and time using the utility
                    DateTime dueDate;
                    try {
                      dueDate = DateTimeParser.parseDateTime(dateText, timeText);
                    } catch (e) {
                      dueDate = DateTime.now();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Invalid date/time format, using current time: $e'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }

                    final newTask = Task(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: title,
                      description: '',
                      dueDate: dueDate,
                      category: category,
                      colorCode: dueDate.isBefore(DateTime.now())
                          ? '#FFAB00' // Amber for In Progress
                          : '#${AppTheme.primary.value.toRadixString(16).padLeft(8, '0').substring(2)}', // Primary for Todo
                    );
                    ref.read(taskProvider.notifier).addTask(newTask);
                    ref.read(taskParseProvider.notifier).reset();
                    _taskController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Task added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to parse task title'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Add Task'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}