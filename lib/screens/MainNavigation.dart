import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:softechapp/screens/HomeScreen.dart';
import 'package:softechapp/screens/TaskScreen.dart';
import 'package:softechapp/screens/CalendarScreen.dart';
import 'package:softechapp/screens/JournalScreen.dart';
import 'package:softechapp/screens/ProfileScreen.dart';
import '../const/theme.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarItems(),
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF262626) 
          : Colors.white,
      navBarStyle: NavBarStyle.simple,
      onItemSelected: (index) {
        // Update selected index
      },
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings(
          animateTabTransition: true,
          duration: Duration(milliseconds: 200),
          screenTransitionAnimationType: ScreenTransitionAnimationType.slide,
        ),
      ),
      navBarHeight: kBottomNavigationBarHeight,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      decoration: NavBarDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        // colorBehindNavBar: Theme.of(context).brightness == Brightness.dark 
        //     ? const Color(0xFF262626) 
        //     : Colors.white,
        // border: Border.all(
        //   color: Theme.of(context).brightness == Brightness.dark 
        //       ? Colors.grey.shade800 
        //       : Colors.white,
        // ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.4),
        //     spreadRadius: 5,
        //     blurRadius: 7,
        //     offset: const Offset(0, 3),
        //   ),
        // ],
      ),
    );
  }

  List<Widget> _buildScreens() {
    return [
      const HomeScreen(),
      const TaskScreen(),
      const CalendarScreen(),
      const JournalScreen(),
      const ProfileScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: 'Home',
        activeColorPrimary: AppTheme.primary,
        inactiveColorPrimary: isDarkMode ? Colors.grey : Colors.grey.shade400,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.list_alt),
        title: 'Tasks',
        activeColorPrimary: AppTheme.primary,
        inactiveColorPrimary: isDarkMode ? Colors.grey : Colors.grey.shade400,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.calendar_today),
        title: 'Calendar',
        activeColorPrimary: AppTheme.primary,
        inactiveColorPrimary: isDarkMode ? Colors.grey : Colors.grey.shade400,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.edit),
        title: 'Journal',
        activeColorPrimary: AppTheme.primary,
        inactiveColorPrimary: isDarkMode ? Colors.grey : Colors.grey.shade400,
      ),
      PersistentBottomNavBarItem(
        icon: const CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage(
            "assets/images/avatarLogo.png", // Placeholder profile image
          ),
        ),
        title: 'Profile',
        activeColorPrimary: AppTheme.primary,
        inactiveColorPrimary: isDarkMode ? Colors.grey : Colors.grey.shade400,
      ),
    ];
  }
} 