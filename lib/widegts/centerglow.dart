// Glow Circle Widget
import 'package:flutter/material.dart';

class CenterGlow extends StatelessWidget {
  const CenterGlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: 500,
          height: 500,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFFB690EF).withOpacity(0.6),
                const Color(0xFF5800C3).withOpacity(0.2),
                Colors.transparent,
              ],
              stops: const [0.2, 0.6, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
