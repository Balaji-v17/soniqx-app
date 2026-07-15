// ============================================================
//  SONIQ — lib/ui/screens/settings_screen.dart
//  App Configuration & Library Sync Management.
// ============================================================
import '../sheets/playback_speed_sheet.dart';
import '../../database/backup_service.dart';
import '../sheets/sleep_timer_sheet.dart';
import 'package:soniq/ui/screens/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soniq/providers.dart';
import 'package:soniq/classifier/language_service.dart';
import 'package:soniq/ui/screens/equalizer_screen.dart'; // 🎯 FIXED: Updated to point to our custom hardware screen
import 'package:soniq/src/providers/scan_notifier.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    // 🎯 DYNAMIC COLORS: These will instantly swap when the theme changes
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final appBarColor = isDarkMode ? const Color(0xFF0A0A0A).withOpacity(0.9) : Colors.white.withOpacity(0.9);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white54 : Colors.black54;
    final dividerColor = isDarkMode ? Colors.white10 : Colors.black12;
    final chevronColor = isDarkMode ? Colors.white24 : Colors.black26;
    final dialogBgColor = isDarkMode ? const Color(0xFF13141F) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor, // 🎯 Use the theme's background color
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          // ─── LIBRARY MANAGEMENT ─────────────────────────────────────
          _buildSectionHeader('Library Management'),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            leading: const Icon(Icons.sync_rounded, color: Color(0xFF6366F1)),
            title: Text('Scan Device for Music', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
            subtitle: Text('Search local storage for new audio files', style: TextStyle(color: subTextColor, fontSize: 13)),
            onTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Scanning local storage for music...'),
                  backgroundColor: Color(0xFF4F46E5),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              
              final scanNotifier = ref.read(scanProvider.notifier);
              await scanNotifier.startFullScan();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Scan complete. Running AI maintenance...'),
                    backgroundColor: Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }

              final aiService = ref.read(languageServiceProvider);
              await aiService.runClassificationPass();
              await aiService.runWeeklyMaintenance();
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            leading: const Icon(Icons.save_rounded, color: Color(0xFFF59E0B)),
            title: Text('Backup & Restore', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
            subtitle: Text('Export your history and playlists to JSON', style: TextStyle(color: subTextColor, fontSize: 13)),
            trailing: Icon(Icons.chevron_right_rounded, color: chevronColor),
            onTap: () async {
              final backupService = ref.read(backupServiceProvider);
              final jsonBackup = await backupService.exportBackup();
              print('📦 BACKUP GENERATED: $jsonBackup');
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Backup generated! Check console output.'),
                    backgroundColor: Color(0xFFF59E0B),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Divider(color: dividerColor, height: 32),
          ),
          
          // ─── APPEARANCE ───────────────────────────────────────────────
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            activeColor: const Color(0xFF818CF8),
            activeTrackColor: const Color(0xFF4F46E5).withOpacity(0.5),
            inactiveThumbColor: isDarkMode ? Colors.white54 : Colors.grey[400],
            inactiveTrackColor: dividerColor,
            secondary: Icon(isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: const Color(0xFF06B6D4)),
            title: Text('Dark Mode', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
            subtitle: Text(isDarkMode ? 'Dark theme active' : 'Light theme active', style: TextStyle(color: subTextColor, fontSize: 13)),
            value: isDarkMode,
            onChanged: (val) {
              ref.read(themeModeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Divider(color: dividerColor, height: 32),
          ),

          // ─── PLAYBACK ───────────────────────────────────────────────
          _buildSectionHeader('Playback'),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            activeColor: const Color(0xFF818CF8),
            activeTrackColor: const Color(0xFF4F46E5).withOpacity(0.5),
            inactiveThumbColor: isDarkMode ? Colors.white54 : Colors.grey[400],
            inactiveTrackColor: dividerColor,
            secondary: Icon(Icons.play_circle_outline_rounded, color: subTextColor),
            title: Text('Gapless Playback', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
            value: true,
            onChanged: (val) {},
          ),
          
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            leading: const Icon(Icons.graphic_eq_rounded, color: Color(0xFFEAB308)),
            title: Text('Equalizer', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
            subtitle: Text('Custom 10-band EQ & Bass Boost', style: TextStyle(color: subTextColor, fontSize: 13)),
            trailing: Icon(Icons.chevron_right_rounded, color: chevronColor),
            // 🎯 FIXED: Replaced showModalBottomSheet with a push navigation to our dynamic EqualizerScreen
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EqualizerScreen(),
                ),
              );
            },
          ),
          
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            leading: const Icon(Icons.query_stats_rounded, color: Color(0xFF10B981)),
            title: Text('Listening Stats', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
            subtitle: Text('View your top tracks and analytics', style: TextStyle(color: subTextColor, fontSize: 13)),
            trailing: Icon(Icons.chevron_right_rounded, color: chevronColor),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Divider(color: dividerColor, height: 32),
          ),

          // ─── ADVANCED ───────────────────────────────────────────────
          _buildSectionHeader('Advanced'),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            leading: const Icon(Icons.smart_toy_rounded, color: Color(0xFFDB2777)),
            title: Text('AI Language Classifier', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
            subtitle: Text('Engine Status: Online', style: TextStyle(color: const Color(0xFF639922).withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500)),
            trailing: Icon(Icons.chevron_right_rounded, color: chevronColor),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: dialogBgColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Row(
                    children: [
                      const Icon(Icons.smart_toy_rounded, color: Color(0xFFDB2777)),
                      const SizedBox(width: 12),
                      Text('SONIQ Engine', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status: Active & Learning', style: TextStyle(color: Color(0xFF639922), fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text('• 4-Signal Heuristic Model loaded\n• Isolate Background Processing active\n• Auto-Learning Feedback Loop enabled\n• Zero-Latency RAM Cache functional',
                        style: TextStyle(color: subTextColor, height: 1.6, fontSize: 14)),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('AWESOME', style: TextStyle(color: Color(0xFFDB2777), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, top: 12.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF6366F1),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}