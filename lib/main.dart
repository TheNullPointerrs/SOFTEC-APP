import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softechapp/firebase_options.dart';
import 'package:softechapp/providers/fontProvider.dart';
import 'package:softechapp/providers/theme_provider.dart';
import 'package:softechapp/screens/ForgotPass.dart';
import 'package:softechapp/screens/LoginScreen.dart';
import 'package:softechapp/screens/MainNavigation.dart';
import 'package:softechapp/screens/NotificationsScreen.dart';
import 'package:softechapp/screens/Onboarding.dart';
import 'package:softechapp/screens/SettingsScreen.dart';
import 'package:softechapp/screens/SignUpScreen.dart';
import 'package:softechapp/screens/SplashScreen.dart';
import 'package:softechapp/services/local_notifications.dart';
import 'const/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    await LocalNotifications.localNotiInit();
    
    runApp(const ProviderScope(child: MyApp()));
  } catch (e) {
    print('Error initializing app: $e');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final selectedFontSize = ref.watch(selectedFontProvider);
    
    // Create copies of the themes with updated font sizes
    final lightTheme = _updateThemeFontSize(AppTheme.lightTheme, selectedFontSize);
    final darkTheme = _updateThemeFontSize(AppTheme.darkTheme, selectedFontSize);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      initialRoute: '/',
      navigatorKey: notificationsNavigatorKey,
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
          case '/notificationsScreen':
            builder = (BuildContext _) => NotificationScreen();
            break;
          case '/settings':
            builder = (BuildContext _) => SettingsScreen();
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
  
  ThemeData _updateThemeFontSize(ThemeData theme, FontSize selectedSize) {
    double baseSize;
    switch (selectedSize) {
      case FontSize.small:
        baseSize = 14.0;
        break;
      case FontSize.medium:
        baseSize = 16.0;
        break;
      case FontSize.large:
        baseSize = 20.0;
        break;
    }
    
    // Calculate scaled font sizes
    final smallSize = baseSize * 0.875;     // 87.5% of base size
    final mediumSize = baseSize;            // base size
    final largeSize = baseSize * 1.25;      // 125% of base size
    final xLargeSize = baseSize * 1.5;      // 150% of base size
    
    return theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        bodyLarge: theme.textTheme.bodyLarge?.copyWith(fontSize: mediumSize),
        bodyMedium: theme.textTheme.bodyMedium?.copyWith(fontSize: smallSize),
        bodySmall: theme.textTheme.bodySmall?.copyWith(fontSize: smallSize * 0.8),
        titleLarge: theme.textTheme.titleLarge?.copyWith(fontSize: largeSize),
        titleMedium: theme.textTheme.titleMedium?.copyWith(fontSize: mediumSize),
        titleSmall: theme.textTheme.titleSmall?.copyWith(fontSize: smallSize),
        headlineLarge: theme.textTheme.headlineLarge?.copyWith(fontSize: xLargeSize * 1.2),
        headlineMedium: theme.textTheme.headlineMedium?.copyWith(fontSize: xLargeSize),
        headlineSmall: theme.textTheme.headlineSmall?.copyWith(fontSize: largeSize),
      ),
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
