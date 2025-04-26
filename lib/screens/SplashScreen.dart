import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});


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
            
          ],
        ),
      ),
    );
  }
}
