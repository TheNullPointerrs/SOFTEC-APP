import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../const/theme.dart';
import '../providers/quote_provider.dart';
import '../providers/task_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/calendar_provider.dart';
import '../widgets/mood_input_modal.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch quote when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quoteProvider.notifier).fetchQuote();
      
      // Ensure mood data is loaded from Firebase
      final moodData = ref.read(moodStreamProvider);
      if (moodData.hasValue && moodData.value!.isNotEmpty) {
        ref.read(moodProvider.notifier).state = moodData.value!;
      }
      
      // Show mood input modal if no mood entry for today
      _checkAndShowMoodPrompt();
    });
  }
  
  void _checkAndShowMoodPrompt() {
    final moodEntries = ref.read(combinedMoodProvider);
    final today = DateTime.now();
    
    // Check if there's an entry for today
    final hasTodayEntry = moodEntries.any((entry) => 
      entry.timestamp.year == today.year && 
      entry.timestamp.month == today.month && 
      entry.timestamp.day == today.day
    );
    
    // Show mood input if no entry for today
    if (!hasTodayEntry) {
      // Delay to ensure the UI is fully loaded
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          MoodInputModal.show(context, onMoodAdded: () {
            setState(() {});
          });
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currentDate = DateTime.now();
    final formatter = DateFormat('dd-MM-yyyy');
    final formattedDate = formatter.format(currentDate);
    
    // Access providers
    final quote = ref.watch(quoteProvider);
    final tasks = ref.watch(taskProvider);
    final moodEntries = ref.watch(combinedMoodProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    // Get ongoing tasks
    final ongoingTasks = tasks.where((task) => !task.isCompleted).toList();
    
    // Get mood entries for display
    final moodHistory = moodEntries.take(3).toList();
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Date and Notification
                Container(
                  margin: const EdgeInsets.only(top: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.black : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.calendar_today, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Today',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(Icons.notifications_outlined, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Date Display
                Text(
                  DateFormat('MMMM d, yyyy').format(selectedDate),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // Calendar Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(7, (index) {
                      final date = DateTime.now().add(Duration(days: index - 1));
                      final isSelected = date.day == selectedDate.day && 
                                       date.month == selectedDate.month && 
                                       date.year == selectedDate.year;
                                       
                      return GestureDetector(
                        onTap: () {
                          ref.read(selectedDateProvider.notifier).state = date;
                        },
                        child: Container(
                          width: 60,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppTheme.primary 
                                : isDarkMode ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('EEEE').format(date).substring(0, 3),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Today's Spark
                Text(
                  "Today's Spark",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // Quote Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.format_quote,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quote['text'] ?? "Believe you can and you're halfway there",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            if (quote['author'] != null && quote['author'].isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "- ${quote['author']}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // On Going Tasks
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "On going tasks",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to task screen
                        DefaultTabController.of(context)?.animateTo(1);
                      },
                      child: Text(
                        "See all",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 10),
                
                // Task Items
                if (ongoingTasks.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFEDEDED),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "No ongoing tasks",
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  )
                else
                  ...ongoingTasks.map((task) {
                    final isCompleted = task.isCompleted;
                    return GestureDetector(
                      onTap: () {
                        // Toggle task completion
                        ref.read(taskProvider.notifier).toggleTaskCompletion(task.id);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFEDEDED),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  color: isCompleted ? Colors.grey : null,
                                ),
                              ),
                            ),
                            Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                color: isCompleted ? Colors.green : null,
                                border: isCompleted
                                    ? null
                                    : Border.all(
                                        color: Colors.green,
                                        width: 2,
                                      ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 18,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                
                const SizedBox(height: 30),
                
                // Mood Analyzer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Mood Analyzer",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(2),
                      child: const Text(
                        "Touch to see",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 15),
                
                // Mood Graph
                GestureDetector(
                  onTap: () {
                    // Show detailed mood history
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Mood History'),
                        content: SizedBox(
                          height: 300,
                          width: 300,
                          child: moodEntries.isEmpty 
                              ? const Center(child: Text('No mood data available'))
                              : LineChart(
                                  LineChartData(
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                    ),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            String text = '';
                                            switch (value.toInt()) {
                                              case 1:
                                                text = '😢';
                                                break;
                                              case 2:
                                                text = '😐';
                                                break;
                                              case 3:
                                                text = '🙂';
                                                break;
                                              case 4:
                                                text = '😊';
                                                break;
                                              case 5:
                                                text = '😁';
                                                break;
                                            }
                                            return Text(text);
                                          },
                                          reservedSize: 40,
                                        ),
                                      ),
                                      rightTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      topTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: true),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: ref.watch(moodProvider.notifier).getLast10Entries()
                                            .map((entry) => FlSpot(
                                                  moodEntries.indexOf(entry).toDouble(),
                                                  entry.rating.toDouble(),
                                                ))
                                            .toList(),
                                        isCurved: true,
                                        color: Colors.blue,
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(show: true),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: Colors.blue.withOpacity(0.1),
                                        ),
                                      ),
                                    ],
                                    minY: 1,
                                    maxY: 5,
                                  ),
                                ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.black12 : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: ref.watch(moodProvider.notifier).getLast10Entries()
                                  .map((entry) => FlSpot(
                                        moodEntries.indexOf(entry).toDouble(),
                                        entry.rating.toDouble(),
                                      ))
                                  .toList(),
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.blue.withOpacity(0.1),
                              ),
                            ),
                          ],
                          minY: 1,
                          maxY: 5,
                          lineTouchData: LineTouchData(enabled: false),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // // Add button for mood
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: GestureDetector(
                //     onTap: () {
                //       // Show mood input dialog
                //       MoodInputModal.show(context);
                //     },
                //     child: Container(
                //       margin: const EdgeInsets.only(top: 10, right: 10),
                //       width: 40,
                //       height: 40,
                //       decoration: BoxDecoration(
                //         color: AppTheme.primary,
                //         borderRadius: BorderRadius.circular(50),
                //       ),
                //       child: const Icon(
                //         Icons.add,
                //         color: Colors.white,
                //       ),
                //     ),
                //   ),
                // ),
                
                const SizedBox(height: 20),
                
                // Mood History
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Mood History",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          Text(
                            DateFormat('dd-MM-yyyy').format(DateTime.now()),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ...moodHistory.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "'${entry.description}'",
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            Text(
                              entry.emoji ?? '😊',
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}