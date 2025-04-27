import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softechapp/providers/notes.dart';
import 'package:softechapp/screens/add_note.dart';
import 'package:softechapp/screens/notedetail.dart';
import 'package:intl/intl.dart'; 

class NotesListScreen extends ConsumerWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes', style: TextStyle(color: Colors.white)),
        backgroundColor: colorScheme.primary, 
        elevation: 5, 
      ),
      body: notesAsync.when(
        data: (notes) {
          final dateFormat = DateFormat('yyyy-MM-dd HH:mm'); 

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              final formattedDate = dateFormat.format(note.createdAt);

              return Card(
                color: colorScheme.surface, // Modern card color
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                elevation: 3, // Add shadow for a lifted effect
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    note.rawNote.length > 30
                        ? '${note.rawNote.substring(0, 30)}...'
                        : note.rawNote,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16, 
                    ),
                  ),
                  subtitle: Text(
                    formattedDate, 
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14, 
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NoteDetailScreen(note: note),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddNoteScreen()),
          );
        },
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.add, size: 30), 
      ),
    );
  }
}
