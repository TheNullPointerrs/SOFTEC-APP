import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softechapp/providers/fontProvider.dart';

/// A widget that consumes the font size provider and applies it to its child's text
class FontSizeText extends ConsumerWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool scaleFactor;

  const FontSizeText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.scaleFactor = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFontSize = ref.watch(selectedFontProvider);
    final fontSizeNotifier = ref.watch(fontSizeProvider.notifier);
    
    // Get the appropriate font size based on selection
    double fontSize;
    switch (selectedFontSize) {
      case FontSize.small:
        fontSize = fontSizeNotifier.small;
        break;
      case FontSize.medium:
        fontSize = fontSizeNotifier.medium;
        break;
      case FontSize.large:
        fontSize = fontSizeNotifier.large;
        break;
    }
    
    // Apply the font size to the style
    final effectiveStyle = (style ?? const TextStyle()).copyWith(
      fontSize: scaleFactor ? style?.fontSize ?? fontSize : fontSize,
    );
    
    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}

/// Extension to apply font sizing to TextStyle
extension FontSizeTextStyle on TextStyle {
  TextStyle withFontSize(BuildContext context, WidgetRef ref) {
    final selectedFontSize = ref.watch(selectedFontProvider);
    final fontSizeNotifier = ref.watch(fontSizeProvider.notifier);
    
    double fontSize;
    switch (selectedFontSize) {
      case FontSize.small:
        fontSize = fontSizeNotifier.small;
        break;
      case FontSize.medium:
        fontSize = fontSizeNotifier.medium;
        break;
      case FontSize.large:
        fontSize = fontSizeNotifier.large;
        break;
    }
    
    return copyWith(fontSize: fontSize);
  }
} 