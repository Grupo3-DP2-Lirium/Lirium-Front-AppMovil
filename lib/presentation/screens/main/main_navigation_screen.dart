import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import '../memories/organize_memories/timeline_screen.dart';
import '../profiles/profiles_screen.dart';
import '../memories/memories_grid_screen.dart';
import '../chat/chat_screen.dart';
import '../settings/settings_screen.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>{
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ProfilesScreen(),
    const MemoriesGridScreen(),
    const ChatScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Memoriales'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Recuerdos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.movie_creation_outlined), label: 'Videos'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outlined), label: 'Cuenta'),
        ],
      ),
    );
  }
}
