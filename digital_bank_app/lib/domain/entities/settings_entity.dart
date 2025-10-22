// lib/domain/entities/settings_entity.dart
import 'package:flutter/material.dart';

class SettingsEntity {
  final Locale language;
  final ThemeMode themeMode;
  final bool notificationsEnabled;

  const SettingsEntity({
    required this.language,
    required this.themeMode,
    required this.notificationsEnabled,
  });

  SettingsEntity copyWith({
    Locale? language,
    ThemeMode? themeMode,
    bool? notificationsEnabled,
  }) {
    return SettingsEntity(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
