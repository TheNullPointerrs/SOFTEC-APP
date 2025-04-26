import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softechapp/providers/fontProvider.dart';
import 'package:softechapp/providers/auth.dart';
import 'package:softechapp/widgets/developer_footer.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../const/theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;
  
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    emailFocusNode.addListener(() {
      setState(() {});
    });
    passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }
  
  Future<void> _signInWithEmail() async {
    final authService = ref.read(authServiceProvider);
    
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      await authService.signInWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        errorMessage = _handleAuthError(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  
  Future<void> _signInWithGoogle() async {
    final authService = ref.read(authServiceProvider);
    
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      await authService.signInWithGoogle();
      
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        errorMessage = _handleAuthError(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  
  String _handleAuthError(String error) {
    if (error.contains('user-not-found')) {
      return 'No user found with this email';
    } else if (error.contains('wrong-password')) {
      return 'Wrong password';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email format';
    } else if (error.contains('user-disabled')) {
      return 'This account has been disabled';
    } else if (error.contains('too-many-requests')) {
      return 'Too many login attempts. Try again later';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Check your connection';
    } else {
      return 'An error occurred. Please try again';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final selectedFont = ref.watch(selectedFontProvider);
    final fontSizeNotifier = ref.watch(fontSizeProvider.notifier);
    
    double getFontSize() {
      switch (selectedFont) {
        case FontSize.small:
          return fontSizeNotifier.small;
        case FontSize.large:
          return fontSizeNotifier.large;
        case FontSize.medium:
        return fontSizeNotifier.medium;
      }
    }
    
    final currentFontSize = getFontSize();
    
    final LinearGradient buttonGradient = LinearGradient(
      colors: isDarkMode 
          ? [Color(0xFF5F0FFF), Color(0xFF911CF1)] 
          : [Color(0xFF9C45FF), Color(0xFF7A0EFF)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final backgroundColor = isDarkMode ? Color(0xFF0B001F) : Color(0xFFF2EAFA);
    
    final textFieldColor = isDarkMode ? Color(0xFF262626) : Color(0xFFEEEEEE);
    
    final primaryTextColor = isDarkMode ? Colors.white : Color(0xFF0C0C0C);
    
    final highlightedBorderColor = AppTheme.firstGradientColor;
    final regularBorderColor = isDarkMode ? Colors.purple[900]! : Colors.purple[200]!;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Image.asset(
                isDarkMode ? 'assets/images/bot.png' : 'assets/images/bot.png',
                height: 60,
                width: 60,
              ),
              const SizedBox(height: 16),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppTheme.firstGradientColor, AppTheme.secondGradientColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'MoodSync',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: currentFontSize * 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Organize Smarter, Feel Better',
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: currentFontSize,
                ),
              ),
              
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: currentFontSize * 0.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email Address',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: currentFontSize,
                      fontWeight: emailFocusNode.hasFocus ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: textFieldColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: emailFocusNode.hasFocus ? highlightedBorderColor : regularBorderColor,
                        width: emailFocusNode.hasFocus ? 2 : 1,
                      ),
                    ),
                    child: TextField(
                      controller: emailController,
                      focusNode: emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: currentFontSize,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: currentFontSize,
                      fontWeight: passwordFocusNode.hasFocus ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: textFieldColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: passwordFocusNode.hasFocus ? highlightedBorderColor : regularBorderColor,
                        width: passwordFocusNode.hasFocus ? 2 : 1,
                      ),
                    ),
                    child: TextField(
                      controller: passwordController,
                      focusNode: passwordFocusNode,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: currentFontSize,
                      ),
                    ),
                  ),
                ],
              ),
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgotPass');
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: AppTheme.firstGradientColor,
                      fontSize: currentFontSize * 0.8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              isLoading
                ? SizedBox(
                    width: 60, // Reduced from 80
                    height: 30, // Reduced from 40
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballPulse,
                      colors: [AppTheme.firstGradientColor],
                    ),
                  )
                : Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: buttonGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton(
                    onPressed: _signInWithEmail,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: currentFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: primaryTextColor.withOpacity(0.3),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: primaryTextColor.withOpacity(0.8),
                          fontSize: currentFontSize * 0.8,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: primaryTextColor.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
              
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                  ),
                  color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white,
                ),
                child: ElevatedButton(
                  onPressed: _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: primaryTextColor,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/google.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Continue with Google',
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: currentFontSize,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(flex: 2),
              
              const SizedBox(height: 16),
              
              DeveloperFooter(
                fontSize: currentFontSize,
                textColor: primaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}