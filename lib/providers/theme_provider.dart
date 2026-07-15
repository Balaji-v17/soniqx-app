import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.dark; 
  }

  Future<void> _loadTheme() async {
    final db = ref.read(databaseProvider);
    final saved = await db.settingsDao.getSetting('theme_mode');
    state = saved == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  Future<void> toggleTheme() async {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final db = ref.read(databaseProvider);
    await db.settingsDao.setSetting('theme_mode', state == ThemeMode.light ? 'light' : 'dark');
  }
}