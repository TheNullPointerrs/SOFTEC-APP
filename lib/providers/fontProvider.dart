import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FontSize {
  small,
  medium,
  large
}

class FontSizeNotifier extends StateNotifier<double> {
  FontSizeNotifier() : super(16.0); // Default font size

  void setFontSize(double newSize) {
    state = newSize;
  }

  double get small => state - 2;
  double get medium => state;
  double get large => state + 4;
}

// Global provider
final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) {
  return FontSizeNotifier();
});

// Selected font size provider
final selectedFontProvider = StateProvider<FontSize>((ref) {
  return FontSize.medium; // Default to medium
});
