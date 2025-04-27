import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softechapp/services/calendar.dart';

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
  final CalendarService _calendarService = CalendarService();

  CalendarNotifier() : super([]) {
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      final events = await _calendarService.getEvents();
      state = events;
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  Future<void> addEvent(CalendarEvent event) async {
    state = [...state, event];
    await _calendarService.addEvent(event);
  }

  Future<void> removeEvent(String id) async {
    state = state.where((event) => event.id != id).toList();
    await _calendarService.removeEvent(id);
  }

  Future<void> updateEvent(CalendarEvent updatedEvent) async {
    state = state.map((event) {
      if (event.id == updatedEvent.id) {
        return updatedEvent;
      }
      return event;
    }).toList();
    await _calendarService.updateEvent(updatedEvent);
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