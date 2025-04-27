import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:softechapp/models/note.dart';

class AIService {
  Future<String> summarizeText(String text) async {
    final url = Uri.parse('https://softec-backend.onrender.com/summarize-note');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['summary'] ?? 'No summary available.';
    } else {
      throw Exception('Failed to summarize text');
    }
  }
}



class NotesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AIService _aiService = AIService();

  Future<void> addSummarizedNote(String rawText) async {
    final userId = _auth.currentUser!.uid;

    final notesCollection = _firestore
        .collection('users')
        .doc(userId)
        .collection('notes');

    final docRef = notesCollection.doc();

    final summarizedText = await _aiService.summarizeText(rawText);

    final newNote = NoteModel(
      id: docRef.id,
      rawNote: rawText,
      summarizedNote: summarizedText,
      createdAt: DateTime.now(),
    );

    await docRef.set(newNote.toMap());
  }
}

