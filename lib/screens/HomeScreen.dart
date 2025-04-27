// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:softechapp/models/task.dart';
import 'package:softechapp/screens/Addtask.dart';
import 'package:softechapp/widegts/mood_input_modal.dart';
import 'package:softechapp/screens/NotificationsScreen.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import '../const/theme.dart';
import '../providers/quote_provider.dart';
import '../providers/task_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/calendar_provider.dart';
import '../services/firebase_storage_service.dart';
import '../services/ocr_service.dart';
import '../utils/image_picker_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

    final FirebaseStorageService _firebaseStorageService = FirebaseStorageService();
  final OCRService _ocrService = OCRService();
  final ImagePickerUtils _imagePickerUtils = ImagePickerUtils();
  
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskOptions(context);
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
                      GestureDetector(
                        onTap: (){
                          // Navigator.of(context).pushNamed('/notificationsScreen');

                          Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationScreen()));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(Icons.notifications_outlined, color: Colors.white),
                        ),
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
                      Container(
                        height: 200,
                        child: moodEntries.isEmpty
                          ? Center(
                              child: Text(
                                "No mood entries yet",
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: moodEntries.length,
                              itemBuilder: (context, index) {
                                final entry = moodEntries[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "'${entry.description}'",
                                              style: TextStyle(
                                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                              ),
                                            ),
                                            Text(
                                              DateFormat('dd MMM, HH:mm').format(entry.timestamp),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        entry.emoji ?? '😊',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                      ),
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

  void _showAddTaskOptions(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF262626) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Add Your Task",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOptionButton(
                    context: context,
                    icon: Icons.camera_alt,
                    label: "OCR",
                    onTap: () {
                      Navigator.pop(context);
                      _captureAndProcessImage();
                    },
                  ),
                  _buildOptionButton(
                    context: context,
                    icon: Icons.text_fields,
                    label: "Text",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AddTaskScreen()));
                    },
                  ),
                  _buildOptionButton(
                    context: context,
                    icon: Icons.mic,
                    label: "Voice",
                    onTap: () {
                      _startVoiceInput();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildOptionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black12 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.3),
              ),
            ),
            child: Icon(
              icon,
              color: AppTheme.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
 
  Future<void> _captureAndProcessImage() async {
    try {
      // Pick an image from gallery or camera
      File? imageFile = await _imagePickerUtils.pickImageFromGallery();
      if (imageFile == null) return;

      // Upload image to Firebase Storage
      String imageUrl = await _firebaseStorageService.uploadImage(imageFile);

      // Send image URL to OCR API
      String extractedText = await _ocrService.sendImageUrlToOCR(imageUrl);

      // Show the extracted text
      _showExtractedTextDialog(extractedText);
    } catch (e) {
      _showErrorDialog("Error: $e");
    }
  }

  void _showExtractedTextDialog(String extractedText) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Extracted Text'),
          content: Text(extractedText),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(error),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  
  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
  
  
  
  void _showTaskInputDialog(BuildContext context, String taskText) {
    final TextEditingController titleController = TextEditingController(text: taskText);
    final TextEditingController descController = TextEditingController();
    DateTime dueDate = DateTime.now();
    String category = 'General';
    
    showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF262626) : Colors.white,
          title: const Text('Add Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  'Due Date: ${DateFormat('dd MMM yyyy').format(dueDate)}',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isNotEmpty) {
                  // Create a new task
                  final newTask = Task(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: title,
                    description: descController.text.trim(),
                    dueDate: dueDate,
                    category: category,
                    colorCode: '#FFAB00',
                  );
                  
                  // Add task to the provider
                  ref.read(taskProvider.notifier).addTask(newTask);
                  Navigator.of(context).pop();
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
              ),
              child: const Text('Add Task'),
            ),
          ],
        );
      },
    );
  }

  // Add speech to text functionality
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  
  Future<void> _startVoiceInput() async {
    Navigator.pop(context);
    _showVoiceInputDialog(context);
  }
  
  void _showVoiceInputDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String recognizedText = '';
    bool isListening = true;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: isDarkMode ? const Color(0xFF262626) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Voice Input', textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Text(
                  isListening ? 'Listening...' : 'Tap to speak',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    if (isListening) {
                      setState(() {
                        isListening = false;
                      });
                      _stopListening();
                    } else {
                      setState(() {
                        isListening = true;
                      });
                      _startListening((text) {
                        setState(() {
                          recognizedText = text;
                        });
                      });
                    }
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isListening ? AppTheme.primary : Colors.grey.shade300,
                    ),
                    child: Center(
                      child: isListening
                          ? _buildAudioWaveAnimation()
                          : Icon(
                              Icons.mic,
                              color: Colors.white,
                              size: 40,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  recognizedText.isEmpty ? 'Say something...' : recognizedText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _stopListening();
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _stopListening();
                  Navigator.of(context).pop();
                  if (recognizedText.isNotEmpty) {
                    _showTaskInputDialog(context, recognizedText);
                  }
                },
                child: const Text('Use Text'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildAudioWaveAnimation() {
    return SizedBox(
      width: 50,
      height: 300,
      child: Lottie.asset(
        'assets/animations/audioSignal.json',
        width: 50,
        height: 200,
        fit: BoxFit.contain,
      ),
    );
  }
  
  Future<void> _startListening(Function(String) onResult) async {
    _isListening = true;
    
    try {
      final speech = SpeechToText();
      bool available = await speech.initialize(
        onStatus: (status) {
          print('Speech status: $status');
          if (status == 'done') {
            _isListening = false;
          }
        },
        onError: (error) {
          print('Speech error: $error');
          _isListening = false;
        },
      );
      
      if (available) {
        speech.listen(
          onResult: (result) {
            final recognizedWords = result.recognizedWords;
            onResult(recognizedWords);
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 5),
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
        );
      } else {
        print('Speech recognition not available');
      }
    } catch (e) {
      print('Error starting speech recognition: $e');
      _isListening = false;
    }
  }
  
  void _stopListening() {
    _isListening = false;
    SpeechToText().stop();
  }
}