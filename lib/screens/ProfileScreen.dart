import 'package:firebase_auth/firebase_auth.dart';  // Import Firebase Auth
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:softechapp/const/theme.dart';
import 'package:softechapp/providers/profile_provider.dart';
import 'package:softechapp/providers/task_provider.dart';
import 'package:softechapp/providers/theme_provider.dart';
import 'package:softechapp/screens/Onboarding.dart';
import 'package:softechapp/services/auth.dart';
import 'package:intl/intl.dart';
import 'package:softechapp/providers/fontProvider.dart';
import 'package:softechapp/widgets/FontSizeConsumer.dart';


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
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate cell size to fill the available width
        final availableWidth = constraints.maxWidth;
        final calculatedCellSize = (availableWidth - (spacing * (columns - 1))) / columns;
        
        return Column(
          children: List.generate(rows, (row) {
            return Padding(
              padding: EdgeInsets.only(bottom: row < rows - 1 ? spacing : 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(columns, (col) {
                  final index = row * columns + col;
                  if (index < data.length) {
                    return Container(
                      width: calculatedCellSize,
                      height: calculatedCellSize,
                      decoration: BoxDecoration(
                        color: data[index].color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  } else {
                    return Container(
                      width: calculatedCellSize,
                      height: calculatedCellSize,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }
                }),
              ),
            );
          }),
        );
      },
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    
    // Fetch user profile from Firebase Authentication
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId == null) {
      return Scaffold(
        body: Center(child: Text("No user found, please log in")),
      );
    }

    // Get current month name
    final currentMonth = DateFormat('MMMM').format(DateTime.now());

    // Fetch user profile using the `userProfileProvider` with the `userId`
    final userProfileAsyncValue = ref.watch(userProfileProvider(userId));
    final tasksList = ref.watch(taskProvider);
    final contributionsData = ref.watch(contributionsDataProvider);

    final int totalTasks = tasksList.length;
    final int completedTasks = tasksList.where((task) => task.isCompleted).length;

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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              "Profile",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.menu, color: textColor),
                onPressed: () {
                  _showLogoutBottomSheet(context);
                },
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
                  color: Theme.of(context).colorScheme.surface,
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
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "$completedTasks Tasks Completed",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "$completedTasks/$totalTasks Tasks",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Progress bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: totalTasks == 0 ? 0 : completedTasks / totalTasks,
                                    backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
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
                      Text(
                        "Progress Tracker",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
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
                                Text(
                                  "Workload balance",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                _buildLegendItem(AppTheme.primary, "Work", textColor),
                                const SizedBox(height: 10),
                                _buildLegendItem(Colors.green, "Study", textColor),
                                const SizedBox(height: 10),
                                _buildLegendItem(Colors.amber, "General", textColor),
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
                          color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Task Streak",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Less",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                    Container(
                                      width: 100,
                                      height: 10,
                                      margin: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
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
                                        color: Theme.of(context).textTheme.bodyMedium?.color,
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
                            const SizedBox(height: 10),
                            Center(
                              child: Text(
                                "Task Streak Of $currentMonth",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
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

  void _showLogoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CustomizationBottomSheet();
      },
    );
  }

  Widget _buildLegendItem(Color color, String title, Color? textColor) {
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

class CustomizationBottomSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeProvider.notifier);
    final currentTheme = ref.watch(themeProvider);
    final isDarkMode = currentTheme == ThemeMode.dark || 
                      (currentTheme == ThemeMode.system && 
                       Theme.of(context).brightness == Brightness.dark);
    
    final selectedFontSize = ref.watch(selectedFontProvider);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          FontSizeText(
            'Customization',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 40),
          
          // Dark theme toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FontSizeText(
                'Enable dark theme',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Switch(
                value: isDarkMode,
                onChanged: (_) {
                  themeNotifier.toggleTheme();
                },
                activeColor: AppTheme.primary,
                activeTrackColor: AppTheme.primary.withOpacity(0.5),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Font size selector
          FontSizeText(
            'Adjust font size',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Font Size Options
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildFontSizeOption(
                context, 
                ref,
                FontSize.small, 
                selectedFontSize, 
                14,
              ),
              const SizedBox(width: 16),
              _buildFontSizeOption(
                context, 
                ref,
                FontSize.medium, 
                selectedFontSize, 
                18,
              ),
              const SizedBox(width: 16),
              _buildFontSizeOption(
                context, 
                ref,
                FontSize.large, 
                selectedFontSize, 
                22,
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          const Divider(thickness: 1),
          
          const SizedBox(height: 40),
          
          // Logout Button
          InkWell(
            onTap: () => _handleLogout(context),
            child: Row(
              children: [
                const Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 12),
                FontSizeText(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildFontSizeOption(
    BuildContext context,
    WidgetRef ref,
    FontSize size,
    FontSize selectedSize,
    double fontSize,
  ) {
    final isSelected = size == selectedSize;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        // Update selected font size
        ref.read(selectedFontProvider.notifier).state = size;
        
        // Update actual font size value
        final fontSizeNotifier = ref.read(fontSizeProvider.notifier);
        switch (size) {
          case FontSize.small:
            fontSizeNotifier.setFontSize(14.0);
            break;
          case FontSize.medium:
            fontSizeNotifier.setFontSize(16.0);
            break;
          case FontSize.large:
            fontSizeNotifier.setFontSize(20.0);
            break;
        }
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppTheme.primary, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            'Aa',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: isSelected 
                  ? AppTheme.primary
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }
  
  void _handleLogout(BuildContext context) async {
    // Store context and close the bottom sheet
    final navigatorContext = Navigator.of(context);
    navigatorContext.pop(); // Close the bottom sheet
    
    // No need to check if mounted here since we're using a locally captured navigator
    
    // Show confirmation dialog with the navigator's context
    final shouldLogout = await showDialog<bool>(
      context: navigatorContext.context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    
    // If the user confirmed logout and the context is still valid
    if (shouldLogout == true && navigatorContext.context.mounted) {
      try {
        // Perform logout (without showing a loading dialog)
        final authService = AuthService();
        await authService.signOut();
        
        // Navigate to login if context is still mounted
        if (navigatorContext.context.mounted) {
          Navigator.push(navigatorContext.context, MaterialPageRoute(builder: (context) => OnboardingScreen()));
        }
      } catch (e) {
        if (navigatorContext.context.mounted) {
          ScaffoldMessenger.of(navigatorContext.context).showSnackBar(
            SnackBar(content: Text('Error logging out: $e')),
          );
        }
      }
    }
  }
}
