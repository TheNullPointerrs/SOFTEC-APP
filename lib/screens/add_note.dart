import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softechapp/services/notes.dart';

class AddNoteScreen extends ConsumerStatefulWidget {
  const AddNoteScreen({super.key});

  @override
  ConsumerState<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends ConsumerState<AddNoteScreen> {
  final TextEditingController _controller = TextEditingController(text:"Flutter is an open-source UI software development kit created by Google. It is used to develop cross-platform applications for Android, iOS, Linux, macOS, Windows, and the web from a single codebase. Flutter apps are built using the Dart programming language and provide a rich, native-like user experience." );
  bool _canSummarize = false;
  bool _isSummarizing = false;
  final NotesService _notesService = NotesService(); // initialize service

  void _checkLength() {
    setState(() {
      _canSummarize = _controller.text.length >= 200;
    });
  }

  Future<void> _summarizeAndSave() async {
    setState(() {
      _isSummarizing = true;
    });

    await _notesService.addSummarizedNote(_controller.text);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_checkLength);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('New Note')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Write your note here...',
                  border: InputBorder.none,
                ),
              ),
            ),
          
          ],
        ),
      ),
      bottomNavigationBar: ElevatedButton(
              onPressed: _canSummarize && !_isSummarizing ? _summarizeAndSave : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canSummarize ? colorScheme.primary : Colors.grey,
              ),
              child: _isSummarizing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary,),
                    )
                  : const Text('Summarize with AI'),
            ),
    );
  }
}
