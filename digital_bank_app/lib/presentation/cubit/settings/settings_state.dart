// lib/presentation/settings/settings_state.dart
import '../../../domain/entities/settings_entity.dart';

abstract class SettingsState {
  final SettingsEntity entity;
  const SettingsState(this.entity);
}

class SettingsInitial extends SettingsState {
  const SettingsInitial(SettingsEntity entity) : super(entity);
}

class SettingsLoaded extends SettingsState {
  const SettingsLoaded(SettingsEntity entity) : super(entity);
}

class SettingsLanguageChanged extends SettingsState {
  const SettingsLanguageChanged(SettingsEntity entity) : super(entity);
}

class SettingsThemeChanged extends SettingsState {
  const SettingsThemeChanged(SettingsEntity entity) : super(entity);
}

class SettingsNotificationChanged extends SettingsState {
  const SettingsNotificationChanged(SettingsEntity entity) : super(entity);
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(SettingsEntity entity, this.message) : super(entity);
}
