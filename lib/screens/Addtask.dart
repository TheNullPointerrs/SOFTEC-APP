import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:softechapp/models/task.dart';
import 'package:softechapp/providers/task_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softechapp/services/local_notifications.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  String? title;
  AddTaskScreen({Key? key, this.title}) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  late TextEditingController titleController;
  final TextEditingController descController = TextEditingController();
  DateTime dueDate = DateTime.now();
  String category = 'General';
  List<String> subtasks = [];
  List<String> subtaskDescriptions = [];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(
      text: widget.title != null && widget.title!.isNotEmpty ? widget.title : '',
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

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

              // Due Date and Time Selection
              Row(
                children: [
                  const Text('Due Date & Time: ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      DateFormat('dd MMM yyyy, h:mm a').format(dueDate),
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDueDateTime,
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text('Add Subtask'),
              ),
              const SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Save Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDueDateTime() async {
    // Select Date
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      // Select Time
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(dueDate),
      );

      if (selectedTime != null) {
        setState(() {
          dueDate = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  List<Widget> _buildSubtaskFields() {
    return List.generate(subtasks.length, (index) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  subtasks[index] = value;
                },
                decoration: InputDecoration(
                  labelText: 'Subtask ${index + 1}',
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black12
                      : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                controller: TextEditingController(text: subtasks[index]),
              ),
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
        colorCode: dueDate.isBefore(DateTime.now()) ? '#FFAB00' : '#${Colors.blueAccent.value.toRadixString(16).padLeft(8, '0').substring(2)}',
        isCompleted: false,
        parentId: '-',
      );

      // Add the main task
      ref.read(taskProvider.notifier).addTask(mainTask);

      // Add subtasks
      for (int i = 0; i < subtasks.length; i++) {
        if (subtasks[i].trim().isNotEmpty) {
          final subtask = Task(
            id: DateTime.now().millisecondsSinceEpoch.toString() + '_$i',
            title: subtasks[i].trim(),
            description: subtaskDescriptions[i],
            dueDate: dueDate,
            category: category,
            colorCode: mainTask.colorCode,
            isCompleted: false,
            parentId: mainTask.id,
          );
          ref.read(taskProvider.notifier).addTask(subtask);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task added successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}