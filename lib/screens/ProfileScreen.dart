import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../const/theme.dart';

// Create a custom ContributionData class to replace ContributionDay
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

// Providers
final userNameProvider = StateProvider<String>((ref) => "Abdullah");
final tasksCompletedProvider = StateProvider<int>((ref) => 7);
final totalTasksProvider = StateProvider<int>((ref) => 10);

final workloadProvider = StateProvider<Map<String, double>>((ref) => {
  "Work": 20,
  "Study": 15,
  "Fitness": 65,
});

// Custom provider for contribution data
final contributionsDataProvider = StateProvider<List<ContributionData>>((ref) {
  // Generate sample contributions data - in a real app, this would come from a database
  List<ContributionData> contributions = [];
  DateTime now = DateTime.now();
  
  // Generate data for the last 96 days (typical GitHub style)
  for (int i = 0; i < 96; i++) {
    DateTime date = now.subtract(Duration(days: 96 - i));
    
    // Create some sample activity levels
    int level = 0;
    if ([12, 13, 15, 39, 40, 47, 58, 69, 75, 86].contains(i)) {
      level = 4; // Maximum level - completed many tasks
    } else if ([26, 50, 81].contains(i)) {
      level = 2; // Medium level - completed some tasks
    }
    
    // Color based on activity level
    Color color;
    if (level == 0) {
      color = Colors.grey.shade800; // No activity
    } else if (level == 2) {
      color = AppTheme.firstGradientColor.withOpacity(0.5); // Medium activity
    } else if (level == 4) {
      color = AppTheme.firstGradientColor; // High activity
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

// Custom widget for contribution grid
class ActivityGrid extends StatelessWidget {
  final List<ContributionData> data;
  final int columns;
  final int rows;
  final double cellSize;
  final double spacing;
  
  const ActivityGrid({
    Key? key,
    required this.data,
    this.columns = 16,
    this.rows = 7,
    this.cellSize = 16.0,
    this.spacing = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: columns * (cellSize + spacing),
      height: rows * (cellSize + spacing),
      child: Column(
        children: List.generate(rows, (row) {
          return Padding(
            padding: EdgeInsets.only(bottom: row < rows - 1 ? spacing : 0),
            child: Row(
              children: List.generate(columns, (col) {
                final index = row * columns + col;
                if (index < data.length) {
                  return Padding(
                    padding: EdgeInsets.only(right: col < columns - 1 ? spacing : 0),
                    child: Container(
                      width: cellSize,
                      height: cellSize,
                      decoration: BoxDecoration(
                        color: data[index].color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.only(right: col < columns - 1 ? spacing : 0),
                    child: Container(
                      width: cellSize,
                      height: cellSize,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }
              }),
            ),
          );
        }),
      ),
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final userName = ref.watch(userNameProvider);
    final tasksCompleted = ref.watch(tasksCompletedProvider);
    final totalTasks = ref.watch(totalTasksProvider);
    final workloadData = ref.watch(workloadProvider);
    final contributionsData = ref.watch(contributionsDataProvider);
    

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0B001F) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              color: Colors.black,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Profile image
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(10),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/avatar.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // User info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Tasks completed",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "$tasksCompleted/$totalTasks",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: tasksCompleted / totalTasks,
                                backgroundColor: Colors.grey.shade800,
                                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                                minHeight: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Progress Tracker
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Progress Tracker",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Workload Balance
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pie Chart
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: workloadData["Work"] ?? 0,
                                color: AppTheme.primary,
                                radius: 50,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: workloadData["Study"] ?? 0,
                                color: Colors.green,
                                radius: 50,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: workloadData["Fitness"] ?? 0,
                                color: Colors.amber,
                                radius: 50,
                                showTitle: false,
                              ),
                            ],
                            sectionsSpace: 0,
                            centerSpaceRadius: 0,
                            startDegreeOffset: 270,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 30),
                      
                      // Legend
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Workload balance",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 15),
                            // Work
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Work",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Study
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Study",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Fitness
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Fitness",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Task Streak - Replace ContributionsChart with our custom ActivityGrid
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Task Streak",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "Less",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  height: 10,
                                  margin: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.grey.shade800,
                                        AppTheme.primary,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                Text(
                                  "More",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Use our custom ActivityGrid instead of ContributionsChart
                        ActivityGrid(
                          data: contributionsData,
                          columns: 12,
                          rows: 8,
                          cellSize: 16,
                          spacing: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}