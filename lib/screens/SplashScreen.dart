import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../const/theme.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _typewriterAnimation;
  final String _appName = "Mood Sync";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _typewriterAnimation = StepTween(begin: 0, end: _appName.length)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn))
      ..addListener(() {
        setState(() {});
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200, // Set desired width
              height: 200, // Set desired height
              child: Lottie.asset(
                'assets/animations/processing-robot.json',
                onLoaded: (composition) {
                  Future.delayed(composition.duration, () {
                    // Check if user is logged in
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      // User is logged in, navigate to main navigation
                      Navigator.pushReplacementNamed(context, '/mainNavigation');
                    } else {
                      // User is not logged in, navigate to onboarding
                      Navigator.pushReplacementNamed(context, '/onboarding');
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [AppTheme.firstGradientColor, AppTheme.secondGradientColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                _appName.substring(0, _typewriterAnimation.value),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Text color is overridden by ShaderMask
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
