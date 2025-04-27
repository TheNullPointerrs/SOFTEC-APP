import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softechapp/firebase_options.dart';
import 'package:softechapp/screens/ForgotPass.dart';
import 'package:softechapp/screens/LoginScreen.dart';
import 'package:softechapp/screens/MainNavigation.dart';
import 'package:softechapp/screens/Onboarding.dart';
import 'package:softechapp/screens/SignUpScreen.dart';
import 'package:softechapp/screens/SplashScreen.dart';
import 'const/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const ProviderScope(child: MyApp()));
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case '/':
            builder = (BuildContext _) => SplashScreen();
            break;
          case '/onboarding':
            builder = (BuildContext _) => OnboardingScreen();
            break;
          case '/login':
            builder = (BuildContext _) => LoginScreen();
            break;  
          case '/signup':
            builder = (BuildContext _) => SignUpScreen();
            break;
          case '/home':
            builder = (BuildContext _) => MainNavigation();
            break;
          case '/forgotPass':
            builder = (BuildContext _) => ForgotPass();
            break;
          case '/mainNavigation':
            builder = (BuildContext _) => MainNavigation();
            break;     

          default:
            throw Exception('Invalid route: ${settings.name}');
        }
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      },
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return SplashScreen();
    } else {
      return SplashScreen();
    }
  }
}
