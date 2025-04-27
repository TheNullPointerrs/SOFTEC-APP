import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:softechapp/providers/calendar_provider.dart';

class CalendarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  Future<List<CalendarEvent>> getEvents() async {
    try {
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return CalendarEvent(
          id: data['id'],
          title: data['title'],
          description: data['description'] ?? '',
          startTime: DateTime.parse(data['startTime']),
          endTime: DateTime.parse(data['endTime']),
          colorCode: data['colorCode'] ?? '#4CAF50',
        );
      }).toList();
    } catch (e) {
      print("Error fetching events from Firestore: $e");
      return [];
    }
  }

  Future<void> addEvent(CalendarEvent event) async {
    try {
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      final eventRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(event.id);

      await eventRef.set({
        'id': event.id,
        'title': event.title,
        'description': event.description,
        'startTime': event.startTime.toIso8601String(),
        'endTime': event.endTime.toIso8601String(),
        'colorCode': event.colorCode,
      });
    } catch (e) {
      print("Error adding event to Firestore: $e");
    }
  }

  Future<void> updateEvent(CalendarEvent event) async {
    try {
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      final eventRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(event.id);

      await eventRef.update({
        'title': event.title,
        'description': event.description,
        'startTime': event.startTime.toIso8601String(),
        'endTime': event.endTime.toIso8601String(),
        'colorCode': event.colorCode,
      });
    } catch (e) {
      print("Error updating event in Firestore: $e");
    }
  }

  Future<void> removeEvent(String eventId) async {
    try {
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .delete();
    } catch (e) {
      print("Error removing event from Firestore: $e");
    }
  }
}