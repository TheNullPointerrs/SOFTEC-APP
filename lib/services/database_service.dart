import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:softechapp/models/UserModel.dart';
import '../providers/mood_provider.dart';

class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;


  static Future<void> addUser(UserModel user) async {
  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

  await userRef.set(user.toMap());
}

static Future<UserModel?> getUserProfile(String userId) async {
  try {
    final userDoc = await _usersCollection.doc(userId).get();
    
    if (userDoc.exists) {
      final data = userDoc.data();
      if (data != null) {
        return UserModel.fromMap(userId, data);  // Pass the userId here
      } else {
        print('No data found for the user');
        return null;
      }
    } else {
      print('User not found.');
      return null; // Return null if user doesn't exist
    }
  } catch (e) {
    print('Error fetching user profile: $e');
    return null; // Return null in case of error
  }
}

  // Collection references
  static CollectionReference<Map<String, dynamic>> get _usersCollection => 
      _firestore.collection('users');
  
  static CollectionReference<Map<String, dynamic>> _moodCollection(String userId) => 
      _usersCollection.doc(userId).collection('moods');

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  // Fetch a random inspirational quote
  static Future<Map<String, dynamic>> fetchQuote() async {
    try {
      final response = await http.get(
        Uri.parse('https://quotes-inspirational-quotes-motivational-quotes.p.rapidapi.com/quote?token=ipworld.info'),
        headers: {
          'x-rapidapi-host': 'quotes-inspirational-quotes-motivational-quotes.p.rapidapi.com',
          'x-rapidapi-key': 'bff4060cf8mshead332a0d7939c6p1b4d4fjsn559c7bbad802',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load quote: ${response.statusCode}');
      }
    } catch (e) {
      // Return default quote if API fails
      return {
        'author': 'Theodore Roosevelt',
        'text': 'Believe you can and you\'re halfway there',
      };
    }
  }

// Add a mood record to Firestore
static Future<String> addMoodRecord({
  required String mood,
  required String note,
  required int rating,
  String? emoji,
}) async {
  try {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Format dates
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    final createdAt = now.toIso8601String();

    // Create record
    final moodData = {
      'createdAt': createdAt,
      'date': dateStr,
      'mood': mood,
      'note': note,
      'rating': rating,
      'emoji': emoji,
    };

    // Add to Firestore
    final docRef = await _moodCollection(userId).add(moodData);
    return docRef.id;
  } catch (e) {
    print('Error adding mood record: $e');
    throw Exception('Failed to add mood record: $e');
  }
}

// Get mood records for the current user
static Stream<List<MoodEntry>> getMoodRecords() {
  final userId = currentUserId;
  if (userId == null) {
    return Stream.value([]);
  }

  return _moodCollection(userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final createdAt = DateTime.parse(data['createdAt'] as String);
      
      return MoodEntry(
        id: doc.id,
        description: data['note'] as String,
        timestamp: createdAt,
        rating: data['rating'] as int,
        emoji: data['emoji'] as String?,
      );
    }).toList();
  });
}
}
