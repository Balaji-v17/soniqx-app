// ============================================================
//  SONIQ — lib/ui/root_screen.dart
//  The core navigation shell and persistent mini-player host.
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/home_screen.dart'; 
import 'screens/search_screen.dart';
import 'screens/playlists_screen.dart'; 
import 'screens/settings_screen.dart';
import 'widgets/mini_player.dart';

class RootScreen extends ConsumerStatefulWidget {
  const RootScreen({super.key});

  @override
  ConsumerState<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends ConsumerState<RootScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 🎯 THE FIX: Move the list inside the build method and remove all 'const' wrappers
    // This stops Dart from trying to strictly evaluate the constructors at compile-time.
    final List<Widget> screens = [
      HomeScreen(),
      SearchScreen(), 
      PlaylistsScreen(), 
      SettingsScreen(),
    ];

    return PopScope(
      canPop: false, 
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: IndexedStack(
                index: _currentIndex,
                children: screens,
              ),
            ),

            const Positioned(
              left: 0,
              right: 0,
              bottom: 0, 
              child: MiniPlayer(),
            ),
          ],
        ),

        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_rounded),
              selectedIcon: Icon(Icons.search_rounded),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.library_music_outlined),
              selectedIcon: Icon(Icons.library_music_rounded),
              label: 'Library',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}