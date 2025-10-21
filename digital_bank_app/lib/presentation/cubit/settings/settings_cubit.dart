// lib/presentation/settings/settings_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/settings_entity.dart';
import '../../../domain/repositories/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository repository;

  SettingsCubit(this.repository)
      : super(const SettingsInitial(
          SettingsEntity(
            language: Locale('vi'),
            themeMode: ThemeMode.light,
            notificationsEnabled: true,
          ),
        ));

  Future<void> load() async {
    try {
      final entity = await repository.getSettings();
      emit(SettingsLoaded(entity));
    } catch (e) {
      emit(SettingsError(state.entity, 'Không thể tải cài đặt'));
    }
  }

  Future<void> changeLanguage(Locale locale) async {
    try {
      await repository.setLanguage(locale);
      final updated = state.entity.copyWith(language: locale);
      emit(SettingsLanguageChanged(updated));
    } catch (e) {
      emit(SettingsError(state.entity, 'Không thể đổi ngôn ngữ'));
    }
  }

  Future<void> changeTheme(ThemeMode mode) async {
    try {
      await repository.setThemeMode(mode);
      final updated = state.entity.copyWith(themeMode: mode);
      emit(SettingsThemeChanged(updated));
    } catch (e) {
      emit(SettingsError(state.entity, 'Không thể đổi giao diện'));
    }
  }

  Future<void> changeNotifications(bool enabled) async {
    try {
      await repository.setNotificationsEnabled(enabled);
      final updated = state.entity.copyWith(notificationsEnabled: enabled);
      emit(SettingsNotificationChanged(updated));
    } catch (e) {
      emit(SettingsError(state.entity, 'Không thể đổi thông báo'));
    }
  }
}
