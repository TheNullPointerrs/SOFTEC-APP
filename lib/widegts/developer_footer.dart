import 'package:flutter/material.dart';

class DeveloperFooter extends StatelessWidget {
  final double fontSize;
  final Color textColor;

  const DeveloperFooter({
    Key? key,
    required this.fontSize,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Developed By ',
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: fontSize * 0.8,
              ),
            ),
            Text(
              'TheNullPointers',
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: fontSize * 0.8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
