import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String? colorCode;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.colorCode,
  });

  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? colorCode,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      colorCode: colorCode ?? this.colorCode,
    );
  }
}

class CalendarNotifier extends StateNotifier<List<CalendarEvent>> {
  CalendarNotifier() : super([
    // Sample events for development
    CalendarEvent(
      id: '1',
      title: 'Team Meeting',
      description: 'Weekly team sync-up',
      startTime: DateTime.now().add(const Duration(hours: 1)),
      endTime: DateTime.now().add(const Duration(hours: 2)),
      colorCode: '#4CAF50',
    ),
    CalendarEvent(
      id: '2',
      title: 'Doctor Appointment',
      description: 'Annual checkup',
      startTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 11)),
      colorCode: '#2196F3',
    ),
  ]);

  void addEvent(CalendarEvent event) {
    state = [...state, event];
  }

  void removeEvent(String id) {
    state = state.where((event) => event.id != id).toList();
  }

  void updateEvent(CalendarEvent updatedEvent) {
    state = state.map((event) {
      if (event.id == updatedEvent.id) {
        return updatedEvent;
      }
      return event;
    }).toList();
  }

  List<CalendarEvent> getEventsByDate(DateTime date) {
    return state.where((event) {
      return event.startTime.year == date.year &&
          event.startTime.month == date.month &&
          event.startTime.day == date.day;
    }).toList();
  }
  
  List<CalendarEvent> getEventsByMonth(int year, int month) {
    return state.where((event) {
      return event.startTime.year == year && event.startTime.month == month;
    }).toList();
  }
}

final calendarProvider = StateNotifierProvider<CalendarNotifier, List<CalendarEvent>>((ref) {
  return CalendarNotifier();
});

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now()); 