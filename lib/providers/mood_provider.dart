import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

class MoodEntry {
  final String id;
  final String description;
  final DateTime timestamp;
  final int rating;
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

final moodStreamProvider = StreamProvider<List<MoodEntry>>((ref) {
  return DatabaseService.getMoodRecords();
});

final combinedMoodProvider = Provider<List<MoodEntry>>((ref) {
  final localMoods = ref.watch(moodProvider);
  final firebaseMoods = ref.watch(moodStreamProvider).valueOrNull ?? [];
  
  final Map<String, MoodEntry> combinedMap = {};
  
  for (final mood in firebaseMoods) {
    combinedMap[mood.id] = mood;
  }
  
  for (final mood in localMoods) {
    combinedMap[mood.id] = mood;
  }
  
  final combined = combinedMap.values.toList();
  combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  
  return combined;
});

class MoodNotifier extends StateNotifier<List<MoodEntry>> {
  final Ref ref;
  
  MoodNotifier(this.ref) : super([]) {
    _initializeData();
  }
  
  void _initializeData() {
    ref.listen(moodStreamProvider, (previous, next) {
      if (next.hasValue && next.value!.isNotEmpty) {
        state = next.value!;
      }
    });
  }
  
  Future<void> addMoodEntry(MoodEntry entry) async {
    try {
      final newEntryId = await DatabaseService.addMoodRecord(
        mood: entry.emoji ?? '😊',
        note: entry.description,
        rating: entry.rating,
        emoji: entry.emoji,
      );
      
      final updatedEntry = entry.copyWith(id: newEntryId);
      state = [...state, updatedEntry];
    } catch (e) {
      print('Error saving to Firebase: $e');
      state = [...state, entry];
    }
  }

  void removeMoodEntry(String id) {
    state = state.where((entry) => entry.id != id).toList();
  }
  
  List<MoodEntry> getLast10Entries() {
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

final moodProvider = StateNotifierProvider<MoodNotifier, List<MoodEntry>>((ref) {
  return MoodNotifier(ref);
});