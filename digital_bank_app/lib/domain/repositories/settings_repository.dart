import 'package:flutter/material.dart';
import '../entities/settings_entity.dart';

abstract class SettingsRepository {
  Future<SettingsEntity> getSettings();
  Future<void> setLanguage(Locale locale);
  Future<void> setThemeMode(ThemeMode mode);
  Future<void> setNotificationsEnabled(bool enabled);
}
