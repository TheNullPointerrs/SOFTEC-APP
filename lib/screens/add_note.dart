import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softechapp/services/notes.dart';

class AddNoteScreen extends ConsumerStatefulWidget {
  const AddNoteScreen({super.key});

  @override
  ConsumerState<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends ConsumerState<AddNoteScreen> {
  final TextEditingController _controller = TextEditingController(text:"The quick brown fox jumps over the lazy dog. This sentence is commonly used to test typing skills and font rendering. It includes every letter of the English alphabet, making it useful for various tasks." );
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
