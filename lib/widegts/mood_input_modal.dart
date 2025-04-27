import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../const/theme.dart';
import '../providers/mood_provider.dart';

class MoodInputModal extends ConsumerStatefulWidget {
  final Function? onMoodAdded;

  const MoodInputModal({
    Key? key,
    this.onMoodAdded,
  }) : super(key: key);

  static void show(BuildContext context, {Function? onMoodAdded}) {
    showDialog(
      context: context,
      builder: (_) => MoodInputModal(onMoodAdded: onMoodAdded),
    );
  }

  @override
  ConsumerState<MoodInputModal> createState() => _MoodInputModalState();
}

class _MoodInputModalState extends ConsumerState<MoodInputModal> {
  int _selectedRating = 3;
  final _noteController = TextEditingController();
  bool _isSubmitting = false;
  
  final Map<int, MoodOption> _moodOptions = {
    1: MoodOption(
      rating: 1,
      emoji: '😢',
      label: 'Sad',
      color: Colors.blue.shade300,
      description: 'Feeling down or upset',
      tag: 'sad',
    ),
    2: MoodOption(
      rating: 2,
      emoji: '😐',
      label: 'Tired',
      color: Colors.blue.shade100,
      description: 'Low energy or exhausted',
      tag: 'tired',
    ),
    3: MoodOption(
      rating: 3,
      emoji: '🙂',
      label: 'stressed',
      color: Colors.yellow.shade200,
      description: 'Neither good nor bad',
      tag: 'stressed',
    ),
    4: MoodOption(
      rating: 4,
      emoji: '😊',
      label: 'Happy',
      color: Colors.orange.shade300,
      description: 'Feeling good today',
      tag: 'happy',
    ),
    5: MoodOption(
      rating: 5,
      emoji: '😁',
      label: 'Energetic',
      color: Colors.green.shade300,
      description: 'Feeling great and motivated',
      tag: 'energetic',
    ),
  };

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitMood() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a mood'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final moodOption = _moodOptions[_selectedRating]!;
      final entryId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final moodEntry = MoodEntry(
        id: entryId,
        description: _noteController.text.isNotEmpty 
            ? _noteController.text 
            : moodOption.description,
        timestamp: DateTime.now(),
        rating: _selectedRating,
        emoji: moodOption.emoji,
      );

      await ref.read(moodProvider.notifier).addMoodEntry(moodEntry);
      
      // Force refresh mood data
      ref.refresh(moodStreamProvider);
      
      if (widget.onMoodAdded != null) {
        widget.onMoodAdded!();
      }
      
      if (mounted) {
        Navigator.of(context).pop();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mood recorded: ${moodOption.label}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {

        
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedMood = _moodOptions[_selectedRating];
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 12,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF262626) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Text(
                'How are you feeling today?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Mood selector
            Container(
              height: 70,
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.black12 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _moodOptions.values.map((option) {
                    final isSelected = _selectedRating == option.rating;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRating = option.rating;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? option.color 
                                : (isDark ? Colors.grey.shade800.withOpacity(0.3) : Colors.white),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: option.color,
                              width: isSelected ? 0 : 1.5,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: option.color.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ] : null,
                          ),
                          child: Center(
                            child: Text(
                              option.emoji,
                              style: TextStyle(
                                fontSize: 18,
                                shadows: isSelected ? [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 2,
                                    offset: const Offset(1, 1),
                                  )
                                ] : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            if (selectedMood != null) ...[
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Container(
                  key: ValueKey(_selectedRating),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: selectedMood.color.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        selectedMood.label,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedMood.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Note input
            TextField(
              controller: _noteController,
              maxLines: 3,
              maxLength: 100,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Add a note (optional)',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.primary,
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: isDark ? Colors.black26 : Colors.grey.shade50,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark ? Colors.white70 : Colors.black54,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitMood,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    shadowColor: AppTheme.primary.withOpacity(0.5),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Mood'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MoodOption {
  final int rating;
  final String emoji;
  final String label;
  final Color color;
  final String description;
  final String tag;

  MoodOption({
    required this.rating,
    required this.emoji,
    required this.label,
    required this.color,
    required this.description,
    required this.tag,
  });
} 