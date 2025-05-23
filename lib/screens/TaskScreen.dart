import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:softechapp/models/task.dart';
import 'package:softechapp/providers/task_provider.dart';
import 'package:softechapp/screens/Addtask.dart';
import '../const/theme.dart';

class TaskScreen extends ConsumerStatefulWidget {
  final DateTime? filterDate;

  const TaskScreen({Key? key, this.filterDate}) : super(key: key);

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    ref.read(taskProvider.notifier).fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final tasks = ref.watch(taskProvider);
    final displayTasks = _filterTasks(tasks);

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
                      _buildFilterChip('Completed'),
                      _buildFilterChip('In Progress'),
                      _buildFilterChip('Todo'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Task> _filterTasks(List<Task> tasks) {
    List<Task> filteredTasks = tasks;
    if (widget.filterDate != null) {
      filteredTasks = tasks.where((task) =>
          task.dueDate.year == widget.filterDate!.year &&
          task.dueDate.month == widget.filterDate!.month &&
          task.dueDate.day == widget.filterDate!.day).toList();
    }

    switch (_selectedFilter) {
      case 'Completed':
        return filteredTasks.where((task) => task.isCompleted).toList();
      case 'In Progress':
        return filteredTasks
            .where((task) => !task.isCompleted && task.dueDate.isBefore(DateTime.now()))
            .toList();
      case 'Todo':
        return filteredTasks
            .where((task) => !task.isCompleted && task.dueDate.isAfter(DateTime.now()))
            .toList();
      case 'All':
      default:
        return filteredTasks;
    }
  }

  // List<Task> _filterTasks(List<Task> tasks) {
  //   List<Task> filteredTasks = tasks;
  //   if (widget.filterDate != null) {
  //     filteredTasks = tasks.where((task) =>
  //         task.dueDate.year == widget.filterDate!.year &&
  //         task.dueDate.month == widget.filterDate!.month &&
  //         task.dueDate.day == widget.filterDate!.day).toList();
  //   }

  //   switch (_selectedFilter) {
  //     case 'Completed':
  //       return filteredTasks.where((task) => task.isCompleted).toList();
  //     case 'In Progress':
  //       return filteredTasks
  //           .where((task) => !task.isCompleted && task.dueDate.isBefore(DateTime.now()))
  //           .toList();
  //     case 'Todo':
  //       return filteredTasks
  //           .where((task) => !task.isCompleted && task.dueDate.isAfter(DateTime.now()))
  //           .toList();
  //     case 'All':
  //     default:
  //       return filteredTasks;
  //   }
  // }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    final colorScheme = Theme.of(context).colorScheme;
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: FilterChip(
        label: Text(label),
        labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        selected: isSelected,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.1),
        selectedColor: AppTheme.primary.withOpacity(0.2),
        checkmarkColor: AppTheme.primary,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Color statusColor;
    if (task.isCompleted) {
      statusColor = Colors.green;
    } else if (task.dueDate.isBefore(DateTime.now())) {
      statusColor = Colors.amber;
    } else {
      statusColor = AppTheme.primary;
    }

    Color borderColor;
    if (task.isCompleted) {
      borderColor = Colors.green;
    } else if (task.dueDate.isBefore(DateTime.now())) {
      borderColor = Colors.green;
    } else {
      borderColor = Colors.white;
    }

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
              color: statusColor,
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
                'Due: ${DateFormat('MMM dd, yyyy, h:mm a').format(task.dueDate)}',
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
                    : Border.all(color: borderColor, width: 2),
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
    DateTime selectedDate = widget.filterDate ?? DateTime.now();

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
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDate),
                    );
                    if (pickedTime != null) {
                      selectedDate = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      // Trigger rebuild to update displayed date/time
                      (context as Element).markNeedsBuild();
                    }
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date & Time',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    DateFormat('MMM dd, yyyy, h:mm a').format(selectedDate),
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
                  isCompleted: false,
                  colorCode: selectedDate.isBefore(DateTime.now())
                      ? '#FFAB00'
                      : '#${AppTheme.primary.value.toRadixString(16).padLeft(8, '0').substring(2)}',
                  parentId: '-',
                );
                ref.read(taskProvider.notifier).addTask(newTask);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a task title'),
                    backgroundColor: Colors.red,
                  ),
                );
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
            Text('Due: ${DateFormat('MMM dd, yyyy, h:mm a').format(task.dueDate)}'),
            const SizedBox(height: 10),
            Text('Category: ${task.category}'),
            const SizedBox(height: 10),
            Text('Status: ${task.isCompleted ? 'Completed' : task.dueDate.isBefore(DateTime.now()) ? 'In Progress' : 'Todo'}'),
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