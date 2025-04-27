import 'package:firebase_auth/firebase_auth.dart';  // Import Firebase Auth
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:softechapp/const/theme.dart';
import 'package:softechapp/providers/profile_provider.dart';
import 'package:softechapp/providers/task_provider.dart';


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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
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
                        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
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
    
    // Fetch user profile from Firebase Authentication
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId == null) {
      return Scaffold(
        body: Center(child: Text("No user found, please log in")),
      );
    }

    // Fetch user profile using the `userProfileProvider` with the `userId`
    final userProfileAsyncValue = ref.watch(userProfileProvider(userId));
    final tasksList = ref.watch(taskProvider);
    final contributionsData = ref.watch(contributionsDataProvider);

    final int totalTasks = tasksList.length;
    final int completedTasks = tasksList.where((task) => task.isCompleted).length;

    // final workloadData = {
    //   "Work": 20,
    //   "Study": 15,
    //   "Fitness": 65,
    // };
    
  // Generate workload data dynamically
  final Map<String, int> workloadData = {};

  // Loop through tasks and categorize them
  for (var task in tasksList) {
    if (task.category != null) {
      workloadData.update(task.category, (value) => value + 1, ifAbsent: () => 1);
    }
  }

  // Optionally, you can set default values or handle empty categories
  if (workloadData.isEmpty) {
    workloadData.addAll({
      "Work": 0,
      "Study": 0,
      "General": 0,
    });
  }

    return userProfileAsyncValue.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            body: Center(child: Text("No user found")),
          );
        }

        final userName = user.name;

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
                                image: AssetImage('assets/images/avatarLogo.png'),
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
                                  "$completedTasks Tasks Completed",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "$completedTasks/$totalTasks Tasks",
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
                                    value: totalTasks == 0 ? 0 : completedTasks / totalTasks,
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
                                    value: (workloadData["Work"] ?? 0).toDouble(),
                                    color: AppTheme.primary,
                                    radius: 50,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    value: (workloadData["Study"] ?? 0).toDouble(),
                                    color: Colors.green,
                                    radius: 50,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    value: (workloadData["General"] ?? 0).toDouble(),
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
                                _buildLegendItem(AppTheme.primary, "Work"),
                                const SizedBox(height: 10),
                                _buildLegendItem(Colors.green, "Study"),
                                const SizedBox(height: 10),
                                _buildLegendItem(Colors.amber, "General"),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Task Streak
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
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildLegendItem(Color color, String title) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
