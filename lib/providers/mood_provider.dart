import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class MoodNotifier extends StateNotifier<List<MoodEntry>> {
  MoodNotifier() : super([
    // Sample mood entries for development
    MoodEntry(
      id: '1',
      description: 'Feeling happy today',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      rating: 5,
      emoji: '😊',
    ),
    MoodEntry(
      id: '2',
      description: 'A bit tired but okay',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      rating: 3,
      emoji: '😐',
    ),
    MoodEntry(
      id: '3',
      description: 'Feeling happy today',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      rating: 4,
      emoji: '😊',
    ),
  ]);

  void addMoodEntry(MoodEntry entry) {
    state = [...state, entry];
  }

  void removeMoodEntry(String id) {
    state = state.where((entry) => entry.id != id).toList();
  }

  void updateMoodEntry(MoodEntry updatedEntry) {
    state = state.map((entry) {
      if (entry.id == updatedEntry.id) {
        return updatedEntry;
      }
      return entry;
    }).toList();
  }

  List<MoodEntry> getMoodEntriesByDate(DateTime date) {
    return state.where((entry) {
      return entry.timestamp.year == date.year &&
          entry.timestamp.month == date.month &&
          entry.timestamp.day == date.day;
    }).toList();
  }

  // Get mood entries for graph visualization
  List<MoodEntry> getLast10Entries() {
    final sortedEntries = [...state];
    sortedEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedEntries.take(10).toList().reversed.toList();
  }
}

final moodProvider = StateNotifierProvider<MoodNotifier, List<MoodEntry>>((ref) {
  return MoodNotifier();
}); 