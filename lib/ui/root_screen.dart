// ============================================================
//  SONIQ — lib/ui/root_screen.dart
//  The core navigation shell and persistent mini-player host.
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/search_screen.dart';
import 'screens/home_screen.dart'; 
import 'widgets/mini_player.dart';
import 'screens/playlists_screen.dart'; 
import 'screens/settings_screen.dart';

class RootScreen extends ConsumerStatefulWidget {
  const RootScreen({super.key});

  @override
  ConsumerState<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends ConsumerState<RootScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(), 
    SearchScreen(), 
    PlaylistsScreen(), 
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // 🎯 THEME ACCESSOR: This reacts instantly to main.dart's themeMode changes
    final colorScheme = Theme.of(context).colorScheme;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return PopScope(
      canPop: false, 
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor: scaffoldBg, 
        
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
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

        // 🎯 DYNAMIC NAVIGATION BAR: Uses the theme's color scheme
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: scaffoldBg, // Responsive to light/dark
          indicatorColor: colorScheme.primary.withOpacity(0.2),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.library_music_outlined),
              selectedIcon: Icon(Icons.library_music),
              label: 'Library',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.queue_music_outlined),
              selectedIcon: Icon(Icons.queue_music),
              label: 'Playlists',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}