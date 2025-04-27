import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:softechapp/models/task.dart';
import 'package:softechapp/providers/task_provider.dart';
import '../const/theme.dart';

class TaskScreen extends ConsumerStatefulWidget {
  final DateTime? filterDate;

  const TaskScreen({Key? key, this.filterDate}) : super(key: key);

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen> {
  bool _showCompleted = true;

  @override
  void initState() {
    super.initState();
    // Fetch tasks when the screen is initialized
    ref.read(taskProvider.notifier).fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);
    final displayTasks = widget.filterDate != null
        ? tasks.where((task) =>
            task.dueDate.year == widget.filterDate!.year &&
            task.dueDate.month == widget.filterDate!.month &&
            task.dueDate.day == widget.filterDate!.day).toList()
        : _showCompleted
            ? tasks
            : tasks.where((task) => !task.isCompleted).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.filterDate != null
                        ? 'Tasks for ${DateFormat('MMM dd, yyyy').format(widget.filterDate!)}'
                        : 'Tasks',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                ],
              ),
              const SizedBox(height: 20),
              if (widget.filterDate == null)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      _buildFilterChip('Today'),
                      _buildFilterChip('Upcoming'),
                      _buildFilterChip('Priority'),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              Expanded(
                child: displayTasks.isEmpty
                    ? Center(
                        child: Text(
                          'No tasks found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      )
                    : ListView.builder(
                        itemCount: displayTasks.length,
                        itemBuilder: (context, index) {
                          final task = displayTasks[index];
                          return _buildTaskItem(task);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _showAddTaskDialog(context);
      //   },
      //   backgroundColor: AppTheme.primary,
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = label == 'All'; // Default selected filter

    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        backgroundColor: Colors.grey.shade200,
        selectedColor: AppTheme.primary.withOpacity(0.2),
        checkmarkColor: AppTheme.primary,
        onSelected: (selected) {
          // Handle filter selection
        },
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Dismissible(
        key: Key(task.id),
        background: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.centerRight,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          ref.read(taskProvider.notifier).removeTask(task.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task "${task.title}" deleted'),
              action: SnackBarAction(
                label: 'UNDO',
                onPressed: () {
                  ref.read(taskProvider.notifier).addTask(task);
                },
              ),
            ),
          );
        },
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          leading: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: task.colorCode != null
                  ? _hexToColor(task.colorCode!)
                  : Colors.amber,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted
                  ? Theme.of(context).disabledColor
                  : Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text(
                'Due: ${DateFormat('MMM dd, yyyy').format(task.dueDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Category: ${task.category}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          trailing: GestureDetector(
            onTap: () {
              ref.read(taskProvider.notifier).toggleTaskCompletion(task.id);
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: task.isCompleted ? Colors.green : null,
                border: task.isCompleted
                    ? null
                    : Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          onTap: () {
            _showTaskDetailsDialog(context, task);
          },
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(selectedDate),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final newTask = Task(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  description: descriptionController.text,
                  dueDate: selectedDate,
                  category: categoryController.text.isNotEmpty
                      ? categoryController.text
                      : 'General',
                  colorCode: '#FFAB00',
                );
                ref.read(taskProvider.notifier).addTask(newTask);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTaskDetailsDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${task.description}'),
            const SizedBox(height: 10),
            Text('Due Date: ${DateFormat('MMM dd, yyyy').format(task.dueDate)}'),
            const SizedBox(height: 10),
            Text('Category: ${task.category}'),
            const SizedBox(height: 10),
            Text('Status: ${task.isCompleted ? 'Completed' : 'Pending'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(taskProvider.notifier).toggleTaskCompletion(task.id);
            },
            child: Text(task.isCompleted ? 'Mark as Incomplete' : 'Mark as Complete'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, task);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(taskProvider.notifier).removeTask(task.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String code) {
    try {
      return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.amber;
    }
  }
}