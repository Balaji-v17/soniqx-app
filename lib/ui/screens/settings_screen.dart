// ============================================================
//  SONIQ — lib/ui/screens/settings_screen.dart
//  App Configuration & Library Sync Management.
// ============================================================
import '../sheets/playback_speed_sheet.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:soniq/database/database.dart';
import 'package:drift/drift.dart' as drift;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:soniq/audio/audio_scanner.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
// import 'package:url_launcher/url_launcher.dart'; // Uncomment after adding the package
import '../../database/backup_service.dart';
import '../sheets/sleep_timer_sheet.dart';
import 'package:soniq/ui/screens/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soniq/providers.dart';
import 'package:soniq/classifier/language_service.dart';
import 'package:soniq/ui/screens/equalizer_screen.dart'; 
import 'package:soniq/src/providers/scan_notifier.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;

    final bgColor = theme.scaffoldBackgroundColor;
    final appBarColor = isDarkMode ? const Color(0xFF0A0A0A).withOpacity(0.9) : Colors.white.withOpacity(0.9);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white54 : Colors.black54;
    final dividerColor = isDarkMode ? Colors.white10 : Colors.black12;
    final chevronColor = isDarkMode ? Colors.white24 : Colors.black26;
    final dialogBgColor = isDarkMode ? const Color(0xFF13141F) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor, 
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
          _buildSectionHeader('Library Management', primaryColor),
          
          // 1. Unified Local Storage & ML Scanner
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            leading: Icon(Icons.sync_rounded, color: primaryColor),
            title: Text('Scan Device for Music', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
            subtitle: Text('Search local storage for new audio files', style: TextStyle(color: subTextColor, fontSize: 13)),
            onTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Scanning local storage for music...'),
                  backgroundColor: primaryColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              
              final languageService = ref.read(languageServiceProvider);
              final scanner = AudioScannerService(db, languageService);
              
              // 1. Find new files on the device
              await scanner.runFullScan();
              
              // 2. Automatically run the AI categorizer on the newly found tracks
              await languageService.runClassificationPass();
              
              // 3. Check for pending user corrections and seed DB updates
              await languageService.runWeeklyMaintenance();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Scan & AI Classification complete!'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          
          // 2. Backup & Restore
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            leading: Icon(Icons.save_rounded, color: primaryColor),
            title: Text('Backup & Restore', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
            subtitle: Text('Export your history and playlists to JSON', style: TextStyle(color: subTextColor, fontSize: 13)),
            trailing: Icon(Icons.chevron_right_rounded, color: chevronColor),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) => AlertDialog(
                  backgroundColor: dialogBgColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Text('Backup & Restore', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                  content: Text('Would you like to export your current library data or restore from an existing backup file?', style: TextStyle(color: subTextColor)),
                  actionsAlignment: MainAxisAlignment.spaceEvenly,
                  actions: [
                    TextButton.icon(
                      onPressed: () async {
                        Navigator.pop(dialogContext); 
                        try {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['json'],
                          );

                          if (result != null && result.files.single.path != null) {
                            final file = File(result.files.single.path!);
                            final jsonString = await file.readAsString();
                            
                            final backupService = ref.read(backupServiceProvider);
                            await backupService.importBackup(jsonString);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('✅ Backup restored successfully!'), backgroundColor: Colors.green),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('⚠️ Restore failed: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      icon: Icon(Icons.download_rounded, color: primaryColor),
                      label: Text('RESTORE', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                    ),
                    
                    ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(dialogContext); 
                        try {
                          final backupService = ref.read(backupServiceProvider);
                          final jsonBackup = await backupService.exportBackup();
                          
                          final directory = await getTemporaryDirectory();
                          final file = File('${directory.path}/soniq_backup.json');
                          await file.writeAsString(jsonBackup);
                          
                          await Share.shareXFiles(
                            [XFile(file.path)],
                            text: 'Soniq App Backup',
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('⚠️ Backup failed: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.upload_rounded),
                      label: const Text('BACKUP'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Divider(color: dividerColor, height: 32),
          ),

          // ─── APPEARANCE ───────────────────────────────────────────────
          _buildSectionHeader('Appearance', primaryColor),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            activeColor: primaryColor,
            activeTrackColor: primaryColor.withValues(alpha: 0.5),
            inactiveThumbColor: isDarkMode ? Colors.white54 : Colors.grey[400],
            inactiveTrackColor: dividerColor,
            secondary: Icon(isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: secondaryColor),
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
          _buildSectionHeader('Playback', primaryColor),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            activeColor: primaryColor,
            activeTrackColor: primaryColor.withValues(alpha: 0.5),
            inactiveThumbColor: isDarkMode ? Colors.white54 : Colors.grey[400],
            inactiveTrackColor: dividerColor,
            secondary: Icon(Icons.play_circle_outline_rounded, color: subTextColor),
            title: Text('Gapless Playback', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
            value: true,
            onChanged: (val) {},
          ),
          
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            leading: Icon(Icons.graphic_eq_rounded, color: primaryColor),
            title: Text('Equalizer', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
            subtitle: Text('Custom 10-band EQ & Bass Boost', style: TextStyle(color: subTextColor, fontSize: 13)),
            trailing: Icon(Icons.chevron_right_rounded, color: chevronColor),
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
            leading: Icon(Icons.query_stats_rounded, color: secondaryColor),
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
          _buildSectionHeader('Advanced', primaryColor),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            leading: Icon(Icons.smart_toy_rounded, color: primaryColor),
            title: Text('AI Language Classifier', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
            subtitle: Text('Engine Status: Online', style: TextStyle(color: Colors.green.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
            trailing: Icon(Icons.chevron_right_rounded, color: chevronColor),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: dialogBgColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Row(
                    children: [
                      Icon(Icons.smart_toy_rounded, color: primaryColor),
                      const SizedBox(width: 12),
                      Text('SONIQ Engine', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: Active & Learning', style: TextStyle(color: Colors.green.shade600, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text('• 4-Signal Heuristic Model loaded\n• Isolate Background Processing active\n• Auto-Learning Feedback Loop enabled\n• Zero-Latency RAM Cache functional',
                        style: TextStyle(color: subTextColor, height: 1.6, fontSize: 14)),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('AWESOME', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Divider(color: dividerColor, height: 32),
          ),

          // ─── ABOUT & LEGAL ──────────────────────────────────────────
          _buildSectionHeader('About & Legal', primaryColor),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            leading: Icon(Icons.privacy_tip_rounded, color: secondaryColor),
            title: Text('Privacy Policy', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
            subtitle: Text('Data Safety and permissions', style: TextStyle(color: subTextColor, fontSize: 13)),
            trailing: Icon(Icons.open_in_new_rounded, color: chevronColor, size: 20),
            onTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Opening Privacy Policy in browser...'),
                  backgroundColor: secondaryColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, top: 12.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}