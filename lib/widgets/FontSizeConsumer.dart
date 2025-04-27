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
    final fontSizeValue = ref.watch(fontSizeProvider);
    
    // Get the appropriate font size based on selection
    double fontSize;
    switch (selectedFontSize) {
      case FontSize.small:
        fontSize = 14.0;
        break;
      case FontSize.medium:
        fontSize = 16.0;
        break;
      case FontSize.large:
        fontSize = 20.0;
        break;
    }
    
    // If style has fontSize and scaleFactor is true, adjust proportionally
    final styleFontSize = style?.fontSize;
    if (styleFontSize != null && scaleFactor) {
      // Use a ratio to maintain proportional sizing
      final baseSize = 16.0; // Medium size as the baseline
      final ratio = fontSize / baseSize;
      fontSize = styleFontSize * ratio;
    }
    
    // Apply the font size to the style
    final effectiveStyle = (style ?? const TextStyle()).copyWith(
      fontSize: fontSize,
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
    
    double fontSize;
    switch (selectedFontSize) {
      case FontSize.small:
        fontSize = 14.0;
        break;
      case FontSize.medium:
        fontSize = 16.0;
        break;
      case FontSize.large:
        fontSize = 20.0;
        break;
    }
    
    return copyWith(fontSize: fontSize);
  }
} 