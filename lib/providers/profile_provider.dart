import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../const/theme.dart';
import '../models/UserModel.dart'; 
import '../services/database_service.dart';
import '../providers/task_provider.dart';

// Create a custom ContributionData class
class ContributionData {
  final DateTime date;
  final int level; // 0-4 where 0 is no activity, 4 is high activity
  final Color color;

  ContributionData({
    required this.date,
    required this.level,
    required this.color,
  });
}

// // User data providers
// final userNameProvider = StateProvider<String>((ref) => "Abdullah");
// final tasksCompletedProvider = StateProvider<int>((ref) => 7);
// final totalTasksProvider = StateProvider<int>((ref) => 10);

// // Workload balance data
// final workloadProvider = StateProvider<Map<String, double>>((ref) => {
//   "Work": 20,
//   "Study": 15,
//   "Fitness": 65,
// });

// // Task streak data with custom ContributionData
// final contributionsDataProvider = StateProvider<List<ContributionData>>((ref) {
//   // In a real app, you'd fetch this data from your database
//   List<ContributionData> contributions = [];
//   final now = DateTime.now();
  
//   // Generate 96 days (8x12 grid)
//   for (int i = 0; i < 96; i++) {
//     final date = now.subtract(Duration(days: 96 - i));
    
//     // Create some specific contributions that match the UI pattern
//     int level = 0;
//     if ([12, 13, 15, 39, 40, 47, 58, 69, 75, 86].contains(i)) {
//       level = 4; // Maximum contribution level - purple cells
//     } else if ([26, 50, 81].contains(i)) {
//       level = 2; // Medium contribution level
//     }
    
//     Color color;
//     if (level == 0) {
//       color = Colors.grey.shade800;
//     } else if (level == 2) {
//       color = AppTheme.firstGradientColor.withOpacity(0.5);
//     } else if (level == 4) {
//       color = AppTheme.firstGradientColor;
//     } else {
//       color = Colors.grey.shade800;
//     }
    
//     contributions.add(ContributionData(
//       date: date,
//       level: level,
//       color: color,
//     ));
//   }
  
//   return contributions;
// });

// Final task streak provider that uses actual task data
final contributionsDataProvider = Provider<List<ContributionData>>((ref) {
  final allTasks = ref.watch(taskCompletionProvider);
  final now = DateTime.now();
  List<ContributionData> contributions = [];
  
  // Generate contribution data for the last 96 days (8x12 grid)
  for (int i = 0; i < 96; i++) {
    final date = now.subtract(Duration(days: 95 - i));
    
    // Format date to compare with task completion dates
    final dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    
    // Check if tasks were completed on this date
    final completedTasksCount = allTasks[dateString] ?? 0;
    
    // Determine level based on completed tasks
    int level = 0;
    if (completedTasksCount > 0) {
      if (completedTasksCount == 1) {
        level = 1;
      } else if (completedTasksCount == 2) {
        level = 2;
      } else if (completedTasksCount == 3) {
        level = 3;
      } else {
        level = 4; // More than 3 tasks
      }
    }
    
    // Determine color based on level
    Color color;
    if (level == 0) {
      color = Colors.grey.shade800;
    } else if (level == 1) {
      color = AppTheme.primary.withOpacity(0.3);
    } else if (level == 2) {
      color = AppTheme.primary.withOpacity(0.5);
    } else if (level == 3) {
      color = AppTheme.primary.withOpacity(0.7);
    } else {
      color = AppTheme.primary;
    }
    
    contributions.add(ContributionData(
      date: date,
      level: level,
      color: color
    ));
  }
  
  return contributions;
});

// Provider to track task completions by date
final taskCompletionProvider = Provider<Map<String, int>>((ref) {
  final tasks = ref.watch(taskProvider);
  final Map<String, int> completionsByDate = {};
  
  for (final task in tasks) {
    if (task.isCompleted) {
      // Format date as YYYY-MM-DD
      final dateString = "${task.dueDate.year}-${task.dueDate.month.toString().padLeft(2, '0')}-${task.dueDate.day.toString().padLeft(2, '0')}";
      
      // Increment count for this date
      completionsByDate[dateString] = (completionsByDate[dateString] ?? 0) + 1;
    }
  }
  
  return completionsByDate;
});

final userProfileProvider = FutureProvider.family<UserModel?, String>((ref, userId) async {
  // Fetch user profile from your database
  final user = await DatabaseService.getUserProfile(userId); // Correct way to call a static method
  return user;
});