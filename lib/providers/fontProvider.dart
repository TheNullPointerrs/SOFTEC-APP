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

  double get small => 14.0;
  double get medium => 16.0;
  double get large => 20.0;
}

// Global provider
final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) {
  return FontSizeNotifier();
});

// Selected font size provider
final selectedFontProvider = StateProvider<FontSize>((ref) {
  final fontSize = ref.watch(fontSizeProvider);
  
  if (fontSize <= 14.0) {
    return FontSize.small;
  } else if (fontSize >= 20.0) {
    return FontSize.large;
  } else {
    return FontSize.medium;
  }
});
