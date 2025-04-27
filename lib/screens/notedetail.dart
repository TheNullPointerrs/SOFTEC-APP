import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softechapp/models/note.dart';
import 'package:softechapp/providers/fontProvider.dart';

class NoteDetailScreen extends ConsumerWidget {
  final NoteModel note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedFont = ref.watch(selectedFontProvider);
    final fontSizeNotifier = ref.watch(fontSizeProvider.notifier);


    double getFontSize() {
      switch (selectedFont) {
        case FontSize.small:
          return fontSizeNotifier.small;
        case FontSize.large:
          return fontSizeNotifier.large;
        case FontSize.medium:
          return fontSizeNotifier.medium;
      }
    }
    
    final currentFontSize = getFontSize();

    return Scaffold(
      backgroundColor: colorScheme.surface, // Set the background to black
      appBar: AppBar(
        title: const Text('Note Detail'),
        backgroundColor: colorScheme.surface, // App bar background
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Allows scrolling if content is large
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Created At: ${note.createdAt}',
                style: TextStyle(
                  fontSize: currentFontSize,
                  color: colorScheme.onSurface, // Lighter white text
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Your Note:',
                style: TextStyle(
                  fontSize: currentFontSize * 1.1,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface, // Text color for title
                ),
              ),
              const SizedBox(height: 10),
              Text(
                note.rawNote,
                style: TextStyle(
                  fontSize: currentFontSize,
                  color: colorScheme.onSurface, // Raw note text color
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Summarized Note:',
                style: TextStyle(
                  fontSize: currentFontSize * 1.1,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface, // Text color for title
                ),
              ),
              const SizedBox(height: 10),
              Text(
                note.summarizedNote,
                style: TextStyle(
                  fontSize: currentFontSize,
                  color: colorScheme.onSurface, // Summarized note text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
