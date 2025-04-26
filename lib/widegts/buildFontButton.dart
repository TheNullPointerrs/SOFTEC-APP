import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softechapp/providers/fontProvider.dart';

Widget buildFontButton(FontSize size, String label, BuildContext context, WidgetRef ref) {
  final selectedFont = ref.watch(selectedFontProvider);
  final isSelected = selectedFont == size;
  final theme = Theme.of(context);
  
  double getFontSize() {
    switch (size) {
      case FontSize.small:
        return 14;
      case FontSize.medium:
        return 18;
      case FontSize.large:
        return 22;
    }
  }
  
  return GestureDetector(
    onTap: () {
      ref.read(selectedFontProvider.notifier).state = size;
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primary.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: getFontSize(),
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ),
  );
}

