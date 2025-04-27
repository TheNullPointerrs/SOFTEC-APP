import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softechapp/models/note.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final notesProvider = StreamProvider<List<NoteModel>>((ref) {
  final userId = FirebaseAuth.instance.currentUser!.uid; // replace it with your auth user id
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('notes')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => NoteModel.fromMap(doc.data(), doc.id))
          .toList());
});

// final addNoteProvider = Provider((ref) => AddNoteService());
