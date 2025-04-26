import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softechapp/providers/fontProvider.dart';
import 'package:softechapp/providers/auth.dart';
import 'package:softechapp/widegts/developer_footer.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../const/theme.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;
  Timer? _verificationTimer;
  
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  
  bool _passwordsMatch = true;
  String _passwordMatchError = '';

  @override
  void initState() {
    super.initState();
    emailFocusNode.addListener(() {
      setState(() {});
    });
    passwordFocusNode.addListener(() {
      setState(() {});
    });
    confirmPasswordFocusNode.addListener(() {
      setState(() {});
    });
    
    confirmPasswordController.addListener(_validatePasswords);
    passwordController.addListener(_validatePasswords);
  }

  void _validatePasswords() {
    if (confirmPasswordController.text.isNotEmpty) {
      setState(() {
        if (passwordController.text != confirmPasswordController.text) {
          _passwordsMatch = false;
          _passwordMatchError = 'Passwords don\'t match';
        } else {
          _passwordsMatch = true;
          _passwordMatchError = '';
        }
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    _verificationTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _signUpWithEmail() async {
    if (!_passwordsMatch) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please ensure passwords match'))
      );
      return;
    }
    
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields'))
      );
      return;
    }
    
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      
      await userCredential.user!.sendEmailVerification();
      
      if (!mounted) return;
      _showVerificationModal(userCredential.user!);
      
    } catch (e) {
      setState(() {
        errorMessage = _handleAuthError(e.toString());
        isLoading = false;
      });
    }
  }
  
  void _showVerificationModal(User user) {
    bool isCheckingVerification = true;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return _buildVerificationDialog(user, isCheckingVerification, (status) {
              setState(() {
                isCheckingVerification = status;
              });
            });
          }
        );
      },
    );
    
    _startVerificationCheck(user, (status) {
      isCheckingVerification = status;
    });
  }
  
  Widget _buildVerificationDialog(
    User user, 
    bool isCheckingVerification, 
    Function(bool) updateCheckingStatus
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final selectedFont = ref.watch(selectedFontProvider);
    final fontSizeNotifier = ref.watch(fontSizeProvider.notifier);
    
    double getFontSize() {
      switch (selectedFont) {
        case FontSize.small: return fontSizeNotifier.small;
        case FontSize.large: return fontSizeNotifier.large;
        case FontSize.medium: return fontSizeNotifier.medium;
      }
    }
    
    final currentFontSize = getFontSize();
    final backgroundColor = isDarkMode ? Color(0xFF262626) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Color(0xFF0C0C0C);
    
    return AlertDialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        children: [
          Icon(
            Icons.mark_email_read,
            size: 48,
            color: AppTheme.firstGradientColor,
          ),
          SizedBox(height: 16),
          Text(
            'Verify Your Email',
            style: TextStyle(
              color: textColor,
              fontSize: currentFontSize * 1.2,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'We\'ve sent a verification email to:',
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: currentFontSize,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            user.email!,
            style: TextStyle(
              color: textColor,
              fontSize: currentFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'Please check your inbox and click the verification link to complete your registration.',
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: currentFontSize * 0.9,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          if (isCheckingVerification) 
            Column(
              children: [
                SizedBox(
                  width: 60,
                  height: 30,
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballPulse,
                    colors: [AppTheme.firstGradientColor],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Checking verification status...',
                  style: TextStyle(
                    color: textColor.withOpacity(0.6),
                    fontSize: currentFontSize * 0.8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _verificationTimer?.cancel();
            Navigator.of(context).pop();
            setState(() {
              isLoading = false;
            });
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.grey,
              fontSize: currentFontSize,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.firstGradientColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () async {
            try {
              await user.sendEmailVerification();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Verification email resent'))
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error resending email. Try again later.'))
              );
            }
          },
          child: Text(
            'Resend Email',
            style: TextStyle(
              fontSize: currentFontSize,
            ),
          ),
        ),
      ],
    );
  }
  
  void _startVerificationCheck(User user, Function(bool) updateCheckingStatus) {
    _verificationTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      await user.reload();
      User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null && currentUser.emailVerified) {
        _verificationTimer?.cancel();
        if (!mounted) return;
        
        updateCheckingStatus(false);
        
        Navigator.of(context).pop();
        
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
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
    if (error.contains('email-already-in-use')) {
      return 'An account already exists for this email';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email format';
    } else if (error.contains('operation-not-allowed')) {
      return 'Email/password accounts are not enabled';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak';
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
    final errorBorderColor = Colors.red;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
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
                  
                const SizedBox(height: 40),
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
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confirm Password',
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: currentFontSize,
                        fontWeight: confirmPasswordFocusNode.hasFocus ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: textFieldColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: !_passwordsMatch 
                              ? errorBorderColor 
                              : (confirmPasswordFocusNode.hasFocus ? highlightedBorderColor : regularBorderColor),
                          width: confirmPasswordFocusNode.hasFocus || !_passwordsMatch ? 2 : 1,
                        ),
                      ),
                      child: TextField(
                        controller: confirmPasswordController,
                        focusNode: confirmPasswordFocusNode,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Confirm your password',
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
                    if (!_passwordsMatch)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _passwordMatchError,
                          style: TextStyle(
                            color: errorBorderColor,
                            fontSize: currentFontSize * 0.8,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                isLoading
                  ? SizedBox(
                      width: 80,
                      height: 40,
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
                      onPressed: _signUpWithEmail,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Sign Up',
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
                
                const SizedBox(height: 60),
                
                DeveloperFooter(
                  fontSize: currentFontSize,
                  textColor: primaryTextColor,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}