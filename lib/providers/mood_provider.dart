import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

class MoodEntry {
  final String id;
  final String description;
  final DateTime timestamp;
  final int rating; // 1-5 where 5 is happiest
  final String? emoji;

  MoodEntry({
    required this.id,
    required this.description,
    required this.timestamp,
    required this.rating,
    this.emoji,
  });

  MoodEntry copyWith({
    String? id,
    String? description,
    DateTime? timestamp,
    int? rating,
    String? emoji,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      rating: rating ?? this.rating,
      emoji: emoji ?? this.emoji,
    );
  }
}

// Map mood ratings to mood tags
String getMoodTag(int rating) {
  switch (rating) {
    case 1:
      return 'sad';
    case 2:
      return 'tired';
    case 3:
      return 'stressed';
    case 4:
      return 'happy';
    case 5:
      return 'energetic';
    default:
      return 'stressed';
  }
}

// Map mood ratings to emoji
String getMoodEmoji(int rating) {
  switch (rating) {
    case 1:
      return '😢';
    case 2:
      return '😐';
    case 3:
      return '🙂';
    case 4:
      return '😊';
    case 5:
      return '😁';
    default:
      return '🙂';
  }
}

// Create stream provider to listen to mood changes from Firebase
final moodStreamProvider = StreamProvider<List<MoodEntry>>((ref) {
  return DatabaseService.getMoodRecords();
});

// Create a combined provider that merges local and Firebase data
final combinedMoodProvider = Provider<List<MoodEntry>>((ref) {
  final localMoods = ref.watch(moodProvider);
  final firebaseMoods = ref.watch(moodStreamProvider).valueOrNull ?? [];
  
  // Combine lists avoiding duplicates
  final Map<String, MoodEntry> combinedMap = {};
  
  // Add Firebase entries first
  for (final mood in firebaseMoods) {
    combinedMap[mood.id] = mood;
  }
  
  // Add local entries (will override Firebase entries with same ID)
  for (final mood in localMoods) {
    combinedMap[mood.id] = mood;
  }
  
  // Convert map back to list and sort by timestamp (newest first)
  final combined = combinedMap.values.toList();
  combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  
  return combined;
});

// Class to manage mood entries
class MoodNotifier extends StateNotifier<List<MoodEntry>> {
  final Ref ref;
  
  MoodNotifier(this.ref) : super([]) {
    // Initialize with data from Firebase stream
    _initializeData();
  }
  
  void _initializeData() {
    // Listen to the Firebase stream and update state when data changes
    ref.listen(moodStreamProvider, (previous, next) {
      if (next.hasValue && next.value!.isNotEmpty) {
        state = next.value!;
      }
    });
  }
  
  // Add a mood entry to local state and Firebase
  Future<void> addMoodEntry(MoodEntry entry) async {
    // Try to save to Firebase first
    try {
      final newEntryId = await DatabaseService.addMoodRecord(
        mood: entry.emoji ?? '😊',
        note: entry.description,
        rating: entry.rating,
        emoji: entry.emoji,
      );
      
      // If successful, use the Firebase ID
      final updatedEntry = entry.copyWith(id: newEntryId);
      state = [...state, updatedEntry];
    } catch (e) {
      // If Firebase fails, still update local state
      print('Error saving to Firebase: $e');
      state = [...state, entry];
    }
  }

  // Remove a mood entry
  void removeMoodEntry(String id) {
    state = state.where((entry) => entry.id != id).toList();
  }
  
  // Get last 10 mood entries
  List<MoodEntry> getLast10Entries() {
    // Get entries from the combined provider to ensure we have all data
    final allEntries = [...state];
    allEntries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    if (allEntries.isEmpty) {
      return [];
    }
    
    if (allEntries.length <= 10) {
      return allEntries;
    }
    
    return allEntries.sublist(allEntries.length - 10);
  }
}

// Provider for mood entries
final moodProvider = StateNotifierProvider<MoodNotifier, List<MoodEntry>>((ref) {
  return MoodNotifier(ref);
}); 