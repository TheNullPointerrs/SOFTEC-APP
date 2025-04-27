import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../const/theme.dart';
import 'package:intl/intl.dart';

// Notification Models
class TaskReminderNotification {
  final String id;
  final String taskName;
  final DateTime deadline;
  final bool isCompleted;

  TaskReminderNotification({
    required this.id,
    required this.taskName,
    required this.deadline,
    this.isCompleted = false,
  });
}

class MissedTaskNotification {
  final String id;
  final String taskName;
  final DateTime missedDeadline;

  MissedTaskNotification({
    required this.id,
    required this.taskName,
    required this.missedDeadline,
  });
}

class UpdateNotification {
  final String id;
  final String message;
  final DateTime timestamp;
  final IconData icon;

  UpdateNotification({
    required this.id,
    required this.message,
    required this.timestamp,
    this.icon = Icons.notifications_outlined,
  });
}

// Sample Data Providers
final taskReminderProvider = StateProvider<List<TaskReminderNotification>>((ref) => [
  TaskReminderNotification(
    id: '1',
    taskName: 'Complete Project Report',
    deadline: DateTime.now().add(const Duration(days: 2)),
  ),
  TaskReminderNotification(
    id: '2',
    taskName: 'Team Meeting Preparation',
    deadline: DateTime.now().add(const Duration(days: 1)),
  ),
]);

final missedTaskProvider = StateProvider<List<MissedTaskNotification>>((ref) => [
  MissedTaskNotification(
    id: '1',
    taskName: 'Submit Assignment',
    missedDeadline: DateTime.now().subtract(const Duration(days: 1)),
  ),
]);

final updateNotificationProvider = StateProvider<List<UpdateNotification>>((ref) => [
  UpdateNotification(
    id: '1',
    message: 'You completed 5 tasks this week!',
    timestamp: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  UpdateNotification(
    id: '2',
    message: 'New feature: Voice notes are now available',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    icon: Icons.new_releases_outlined,
  ),
]);

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Read data from providers
    final taskReminders = ref.watch(taskReminderProvider);
    final missedTasks = ref.watch(missedTaskProvider);
    final updates = ref.watch(updateNotificationProvider);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : AppTheme.primary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [const Color(0xFF0B001F), Colors.black]
                : [Colors.white, const Color(0xFFF5F5F5)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reminders
                  Text(
                    'Reminders',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Task Reminders List
                  if (taskReminders.isEmpty)
                    _buildEmptyState('No upcoming task reminders'),
                  ...taskReminders.map((reminder) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildTaskReminder(context, reminder),
                  )),
                  
                  const SizedBox(height: 30),
                  
                  // Missed Tasks
                  Text(
                    'Missed Tasks',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Missed Tasks List
                  if (missedTasks.isEmpty)
                    _buildEmptyState('No missed tasks'),
                  ...missedTasks.map((task) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildMissedTask(context, task),
                  )),
                  
                  const SizedBox(height: 30),
                  
                  // Updates section
                  Text(
                    'Updates',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Updates List
                  if (updates.isEmpty)
                    _buildEmptyState('No updates'),
                  ...updates.map((update) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildUpdateNotification(context, update),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
  
  Widget _buildTaskReminder(BuildContext context, TaskReminderNotification notification) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final formatter = DateFormat('dd-MM-yyyy');
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF6A1B9A).withOpacity(0.8) : AppTheme.primary.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.taskName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Deadline: ${formatter.format(notification.deadline)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50), // Green button color
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMissedTask(BuildContext context, MissedTaskNotification notification) {
    final formatter = DateFormat('dd-MM-yyyy');
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.taskName,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Missed deadline: ${formatter.format(notification.missedDeadline)}',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildUpdateNotification(BuildContext context, UpdateNotification notification) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final formatter = DateFormat('dd-MM-yyyy');
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF333333) : Colors.grey.shade200, // Dark gray for notification
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            notification.icon,
            color: isDarkMode ? Colors.white : AppTheme.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.message,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatter.format(notification.timestamp),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}