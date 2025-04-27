import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:softechapp/models/task.dart';
import 'package:softechapp/providers/task_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softechapp/services/local_notifications.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  DateTime dueDate = DateTime.now();
  String category = 'General';
  List<String> subtasks = []; // Store subtasks
  List<String> subtaskDescriptions = []; // Store subtask descriptions

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
        backgroundColor: isDarkMode ? Colors.black : Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Title Field
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  filled: true,
                  fillColor: isDarkMode ? Colors.black12 : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Task Description Field
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  filled: true,
                  fillColor: isDarkMode ? Colors.black12 : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Due Date Selection
              Row(
                children: [
                  const Text('Due Date: ', style: TextStyle(fontSize: 16)),
                  Text(
                    DateFormat('dd MMM yyyy').format(dueDate),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDueDate,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Subtask Section
              const Text(
                'Subtasks:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ..._buildSubtaskFields(),
              ElevatedButton(
                onPressed: _addSubtask,
                child: const Text('Add Subtask'),
              ),
              const SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text('Save Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null && selectedDate != dueDate) {
      setState(() {
        dueDate = selectedDate;
      });
    }
  }

  // Build the subtask fields dynamically
  List<Widget> _buildSubtaskFields() {
    return List.generate(subtasks.length, (index) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(subtasks[index]),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => _removeSubtask(index),
            ),
          ],
        ),
      );
    });
  }

  // Add a new subtask
  void _addSubtask() {
    setState(() {
      subtasks.add('New Subtask');
      subtaskDescriptions.add(''); 
    });
  }

  void _removeSubtask(int index) {
    setState(() {
      subtasks.removeAt(index);
      subtaskDescriptions.removeAt(index); 
    });
  }

void _saveTask() async {
  final title = titleController.text.trim();
  if (title.isNotEmpty) {
    final mainTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: descController.text.trim(),
      dueDate: dueDate,
      category: category,
      colorCode: '#FFAB00',
      parentId: '-', 
    );

    // Add the main task first, then subtasks
    ref.read(taskProvider.notifier).addTask(mainTask);
    
    // Schedule notification 12 hours before the due date
    DateTime notificationTime = dueDate.subtract(const Duration(hours: 12));
    // Only schedule if notification time is in the future
    if (notificationTime.isAfter(DateTime.now())) {
      await LocalNotifications.showScheduleNotification(
        title: 'Task Reminder',
        body: 'Your task "$title" is due in 12 hours',
        payload: mainTask.id,
        scheduledTime: notificationTime,
      );
    }

    // Add subtasks
    for (int i = 0; i < subtasks.length; i++) {
      final subtask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: subtasks[i],
        description: subtaskDescriptions[i],
        dueDate: dueDate, 
        category: category,
        colorCode: '#FFAB00',
        parentId: mainTask.id, 
      );
      ref.read(taskProvider.notifier).addTask(subtask);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task added successfully'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
}

}
