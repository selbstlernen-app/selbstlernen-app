import 'package:flutter/material.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/screens/add_session/add_session_screen.dart';
import 'package:srl_app/presentation/screens/general_statistics/statistics_screen.dart';
import 'package:srl_app/presentation/screens/home/home_screen.dart';
import 'package:srl_app/presentation/screens/settings/settings_screen.dart';

/// Main navigation bar of the application
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const <Widget>[
    HomeScreen(),
    AddSessionScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: context.colorScheme.primary,
        unselectedItemColor: context.colorScheme.onTertiary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _selectedIndex == 0
                ? const Icon(Icons.home)
                : const Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 1
                ? const Icon(Icons.add_box_rounded)
                : const Icon(Icons.add_box_outlined),
            label: 'Neue Einheit',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Statistik',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 3
                ? const Icon(Icons.settings)
                : const Icon(Icons.settings_outlined),
            label: 'Einstellungen',
          ),
        ],
      ),
    );
  }
}
