import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:softechapp/screens/HomeScreen.dart';
import 'package:softechapp/screens/TaskScreen.dart';
import 'package:softechapp/screens/CalendarScreen.dart';
import 'package:softechapp/screens/ProfileScreen.dart';
import 'package:softechapp/screens/notesList.dart';
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
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
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
    
    );
  }

  List<Widget> _buildScreens() {
    return [
      const HomeScreen(),
      const TaskScreen(),
      const CalendarScreen(),
      NotesListScreen(),
      ProfileScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return [
      PersistentBottomNavBarItem(
        icon: PhosphorIcon(PhosphorIcons.house(PhosphorIconsStyle.fill)),
        activeColorPrimary: AppTheme.primary,
        inactiveColorPrimary: isDarkMode ? Colors.grey : Colors.grey.shade400,
      ),
      PersistentBottomNavBarItem(
        icon: PhosphorIcon(PhosphorIcons.listChecks(PhosphorIconsStyle.fill)),
        activeColorPrimary: AppTheme.primary,
        inactiveColorPrimary: isDarkMode ? Colors.grey : Colors.grey.shade400,
      ),
      PersistentBottomNavBarItem(
        icon: PhosphorIcon(PhosphorIcons.calendar(PhosphorIconsStyle.fill)),
        activeColorPrimary: AppTheme.primary,
        inactiveColorPrimary: isDarkMode ? Colors.grey : Colors.grey.shade400,
      ),
      PersistentBottomNavBarItem(
        icon: PhosphorIcon(PhosphorIcons.notePencil(PhosphorIconsStyle.fill)),
        activeColorPrimary: AppTheme.primary,
        inactiveColorPrimary: isDarkMode ? Colors.grey : Colors.grey.shade400,
      ),
      PersistentBottomNavBarItem(
        icon: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _controller.index == 4 ? AppTheme.primary : Colors.transparent,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              "assets/images/avatarLogo.png",
              fit: BoxFit.cover,
            ),
          ),
        ),
        activeColorPrimary: Colors.transparent,
        inactiveColorPrimary: Colors.transparent,
      ),
    ];
  }
} 