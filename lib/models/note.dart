import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String rawNote;
  final String summarizedNote;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.rawNote,
    required this.summarizedNote,
    required this.createdAt,
  });

  factory NoteModel.fromMap(Map<String, dynamic> map, String id) {
    return NoteModel(
      id: id,
      rawNote: map['rawNote'] ?? '',
      summarizedNote: map['summarizedNote'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rawNote': rawNote,
      'summarizedNote': summarizedNote,
      'createdAt': createdAt,
    };
  }
}
