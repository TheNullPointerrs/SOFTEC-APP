import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softechapp/const/theme.dart';
import 'package:softechapp/providers/fontProvider.dart';
import 'package:softechapp/screens/Onboarding.dart';
import 'package:softechapp/services/auth.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final selectedFontSize = ref.watch(selectedFontProvider);
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0B001F) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : AppTheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Customization',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dark Theme Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enable dark theme',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Switch(
                  value: isDarkMode,
                  onChanged: (_) {
                    // This is just a UI placeholder as the theme is managed by the system
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Theme is controlled by your system settings'),
                      ),
                    );
                  },
                  activeColor: AppTheme.primary,
                  activeTrackColor: AppTheme.primary.withOpacity(0.5),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Font Size Selector
            Text(
              'Adjust font size',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Font Size Options
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildFontSizeOption(
                  context, 
                  ref,
                  FontSize.small, 
                  selectedFontSize, 
                  14,
                ),
                const SizedBox(width: 16),
                _buildFontSizeOption(
                  context, 
                  ref,
                  FontSize.medium, 
                  selectedFontSize, 
                  18,
                ),
                const SizedBox(width: 16),
                _buildFontSizeOption(
                  context, 
                  ref,
                  FontSize.large, 
                  selectedFontSize, 
                  22,
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            const Divider(thickness: 1),
            
            const SizedBox(height: 40),
            
            // Logout Button
            InkWell(
              onTap: () => _handleLogout(context),
              child: Row(
                children: [
                  const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFontSizeOption(
    BuildContext context,
    WidgetRef ref,
    FontSize size,
    FontSize selectedSize,
    double fontSize,
  ) {
    final isSelected = size == selectedSize;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        // Update selected font size
        ref.read(selectedFontProvider.notifier).state = size;
        
        // Update actual font size value
        final fontSizeNotifier = ref.read(fontSizeProvider.notifier);
        switch (size) {
          case FontSize.small:
            fontSizeNotifier.setFontSize(14.0);
            break;
          case FontSize.medium:
            fontSizeNotifier.setFontSize(16.0);
            break;
          case FontSize.large:
            fontSizeNotifier.setFontSize(20.0);
            break;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Font size updated to ${size.name}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppTheme.primary, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            'Aa',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: isSelected 
                  ? AppTheme.primary
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }
  
  void _handleLogout(BuildContext context) async {
    // Store context mounted state in a variable to check later
    final navigatorContext = context;
    
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    
    // Check if context is still valid and user confirmed logout
    if (shouldLogout == true && navigatorContext.mounted) {
      try {
        // Perform logout (don't show loading indicator as it can cause context issues)
        final authService = AuthService();
        await authService.signOut();
        
        // Navigate to onboarding if context is still mounted
        if (navigatorContext.mounted) {
          Navigator.pushAndRemoveUntil(
            navigatorContext,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
            (route) => false
          );
        }
      } catch (e) {
        // Show error if context is still mounted
        if (navigatorContext.mounted) {
          ScaffoldMessenger.of(navigatorContext).showSnackBar(
            SnackBar(content: Text('Error logging out: $e')),
          );
        }
      }
    }
  }
} 