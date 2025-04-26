import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softechapp/providers/fontProvider.dart';
import 'package:softechapp/widegts/centerglow.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _moveUpDown;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _moveUpDown = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotate = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = ref.watch(fontSizeProvider);
    final fontSizeNotifier = ref.watch(fontSizeProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          const CenterGlow(), // Extracted Glow Widget

          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Robot Image
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _moveUpDown.value),
                        child: Transform.rotate(
                          angle: _rotate.value,
                          child: child,
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/images/bot.png',
                      height: 180,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // App Title
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: fontSizeNotifier.large * 2,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                      children: [
                        const TextSpan(text: 'Mood'),
                        TextSpan(
                          text: 'Sync',
                          style: TextStyle(
                            color: colorScheme.primary.withValues(alpha:0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      'Your ultimate companion for university life.\nDiscover features designed to help you stay organized, connected, and successful.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: fontSizeNotifier.medium * 0.8,
                        color: colorScheme.onSurface.withValues(alpha:0.7),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Login Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        side: BorderSide(color: colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Navigate to Login
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: fontSizeNotifier.medium,
                          color: colorScheme.onSurface,

                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sign Up Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Navigate to Sign Up
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFB690EF),
                                Color(0xFF5800C3),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: fontSizeNotifier.medium,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

