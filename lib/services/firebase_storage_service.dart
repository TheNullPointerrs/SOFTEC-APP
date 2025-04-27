import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File imageFile) async {
    try {
      // Create a unique file name using current time
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload the file to Firebase Storage
      TaskSnapshot snapshot = await _storage.ref('uploads/$fileName').putFile(imageFile);

      // Get the URL of the uploaded image
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl; // Returning the image URL
    } on FirebaseException catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}