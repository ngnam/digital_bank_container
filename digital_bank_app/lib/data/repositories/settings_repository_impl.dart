// lib/data/repositories/settings_repository.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';


class SettingsRepositoryImpl implements SettingsRepository {
  static const _keyLanguage = 'settings.language';
  static const _keyThemeMode = 'settings.themeMode';
  static const _keyNotifications = 'settings.notificationsEnabled';

  @override
  Future<SettingsEntity> getSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final langCode = prefs.getString(_keyLanguage) ?? 'vi';
    final themeIndex = prefs.getInt(_keyThemeMode) ?? ThemeMode.light.index;
    final notifications = prefs.getBool(_keyNotifications) ?? true;

    return SettingsEntity(
      language: Locale(langCode),
      themeMode: ThemeMode.values[themeIndex],
      notificationsEnabled: notifications,
    );
  }

  @override
  Future<void> setLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, locale.languageCode);
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, enabled);
  }
}
