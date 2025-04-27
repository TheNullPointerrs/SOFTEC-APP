import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softechapp/providers/fontProvider.dart';
import 'package:softechapp/providers/auth.dart';
import 'package:softechapp/widegts/developer_footer.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../const/theme.dart';

class ForgotPass extends ConsumerStatefulWidget {
  const ForgotPass({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPass> createState() => _ForgotPassState();
}

class _ForgotPassState extends ConsumerState<ForgotPass> {
  final emailController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;
  
  final FocusNode emailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    emailFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    emailFocusNode.dispose();
    super.dispose();
  }
  
  Future<void> _resetPassword() async {
    final authService = ref.read(authServiceProvider);
    
    if (emailController.text.trim().isEmpty) {
      setState(() {
        errorMessage = 'Please enter your email address';
      });
      return;
    }
    
    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });
    try {
      await authService.sendPasswordResetEmail(emailController.text.trim());
      
      setState(() {
        successMessage = 'Password reset email sent. Please check your inbox.';
      });
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
    } else if (error.contains('invalid-email')) {
      return 'Invalid email format';
    } else if (error.contains('user-disabled')) {
      return 'This account has been disabled';
    } else if (error.contains('too-many-requests')) {
      return 'Too many requests. Try again later';
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
              const SizedBox(height: 40),
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
                  'Reset Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: currentFontSize * 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter your email address and we\'ll send you a link to reset your password',
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: currentFontSize,
                ),
                textAlign: TextAlign.center,
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
              
              if (successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    successMessage!,
                    style: TextStyle(
                      color: Colors.green,
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
              
              const SizedBox(height: 24),
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
                    onPressed: _resetPassword,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Reset Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: currentFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Back to Login',
                    style: TextStyle(
                      color: AppTheme.firstGradientColor,
                      fontSize: currentFontSize * 0.9,
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}