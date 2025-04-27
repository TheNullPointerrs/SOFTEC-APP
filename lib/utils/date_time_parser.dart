import 'package:intl/intl.dart';

class DateTimeParser {
  static DateTime parseDateTime(String? dateText, String? timeText) {
    DateTime baseDate = DateTime.now();
    DateTime? parsedDate;

    // Parse date
    if (dateText != null && dateText.isNotEmpty) {
      final lowerDate = dateText.toLowerCase().trim();
      if (lowerDate == 'today') {
        parsedDate = DateTime(baseDate.year, baseDate.month, baseDate.day);
      } else if (lowerDate == 'tomorrow') {
        parsedDate = baseDate.add(const Duration(days: 1));
        parsedDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
      } else if (lowerDate.startsWith('next ')) {
        final dayName = lowerDate.substring(5).trim();
        parsedDate = _getNextDayOfWeek(dayName, baseDate);
      } else {
        // Try parsing specific dates (e.g., "2025-04-28" or "April 28, 2025")
        try {
          parsedDate = DateFormat('yyyy-MM-dd').parse(lowerDate);
        } catch (_) {
          try {
            parsedDate = DateFormat('MMMM d, yyyy').parse(lowerDate);
          } catch (_) {
            // Fallback to today if date parsing fails
            parsedDate = DateTime(baseDate.year, baseDate.month, baseDate.day);
          }
        }
      }
    } else {
      // Default to today if no date provided
      parsedDate = DateTime(baseDate.year, baseDate.month, baseDate.day);
    }

    // Parse time
    if (timeText != null && timeText.isNotEmpty) {
      final lowerTime = timeText.toLowerCase().trim();
      final timeMatch = RegExp(r'(\d{1,2})(?::(\d{2}))?\s*(am|pm)?', caseSensitive: false).firstMatch(lowerTime);
      if (timeMatch != null) {
        int hour = int.parse(timeMatch.group(1)!);
        int minute = timeMatch.group(2) != null ? int.parse(timeMatch.group(2)!) : 0;
        final period = timeMatch.group(3);

        if (period != null) {
          if (period == 'pm' && hour < 12) {
            hour += 12;
          } else if (period == 'am' && hour == 12) {
            hour = 0;
          }
        } else if (hour >= 1 && hour <= 12) {
          // Assume PM for hours like "7" (heuristic for evening tasks)
          hour = hour < 6 ? hour + 12 : hour;
        }

        parsedDate = DateTime(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
          hour,
          minute,
        );
      } else if (lowerTime.contains(':')) {
        // Try parsing 24-hour format (e.g., "14:30")
        try {
          final parsedTime = DateFormat('HH:mm').parse(lowerTime);
          parsedDate = DateTime(
            parsedDate.year,
            parsedDate.month,
            parsedDate.day,
            parsedTime.hour,
            parsedTime.minute,
          );
        } catch (_) {
          // Fallback to parsed date without time change
        }
      }
    }

    return parsedDate!;
  }

  static DateTime _getNextDayOfWeek(String dayName, DateTime baseDate) {
    final daysOfWeek = {
      'monday': 1,
      'tuesday': 2,
      'wednesday': 3,
      'thursday': 4,
      'friday': 5,
      'saturday': 6,
      'sunday': 7,
    };

    final targetDay = daysOfWeek[dayName.toLowerCase()];
    if (targetDay == null) {
      return DateTime(baseDate.year, baseDate.month, baseDate.day);
    }

    int currentDay = baseDate.weekday;
    int daysUntilTarget = (targetDay - currentDay + 7) % 7;
    if (daysUntilTarget == 0) {
      daysUntilTarget = 7; // Next week
    }

    return baseDate.add(Duration(days: daysUntilTarget));
  }
}