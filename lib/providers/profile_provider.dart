import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../const/theme.dart';

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

// User data providers
final userNameProvider = StateProvider<String>((ref) => "Abdullah");
final tasksCompletedProvider = StateProvider<int>((ref) => 7);
final totalTasksProvider = StateProvider<int>((ref) => 10);

// Workload balance data
final workloadProvider = StateProvider<Map<String, double>>((ref) => {
  "Work": 20,
  "Study": 15,
  "Fitness": 65,
});

// Task streak data with custom ContributionData
final contributionsDataProvider = StateProvider<List<ContributionData>>((ref) {
  // In a real app, you'd fetch this data from your database
  List<ContributionData> contributions = [];
  final now = DateTime.now();
  
  // Generate 96 days (8x12 grid)
  for (int i = 0; i < 96; i++) {
    final date = now.subtract(Duration(days: 96 - i));
    
    // Create some specific contributions that match the UI pattern
    int level = 0;
    if ([12, 13, 15, 39, 40, 47, 58, 69, 75, 86].contains(i)) {
      level = 4; // Maximum contribution level - purple cells
    } else if ([26, 50, 81].contains(i)) {
      level = 2; // Medium contribution level
    }
    
    Color color;
    if (level == 0) {
      color = Colors.grey.shade800;
    } else if (level == 2) {
      color = AppTheme.firstGradientColor.withOpacity(0.5);
    } else if (level == 4) {
      color = AppTheme.firstGradientColor;
    } else {
      color = Colors.grey.shade800;
    }
    
    contributions.add(ContributionData(
      date: date,
      level: level,
      color: color,
    ));
  }
  
  return contributions;
});
