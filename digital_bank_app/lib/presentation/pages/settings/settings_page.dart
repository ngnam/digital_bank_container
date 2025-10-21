// lib/presentation/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/settings/settings_cubit.dart';
import '../../cubit/settings/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  List<DropdownMenuItem<Locale>> _languageItems() {
    return const [
      DropdownMenuItem(
        value: Locale('vi'),
        child: Text('Tiếng Việt'),
      ),
      DropdownMenuItem(
        value: Locale('en'),
        child: Text('English'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final entity = state.entity;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Cài đặt'),
            centerTitle: true,
          ),
          body: ListView(
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Ngôn ngữ'),
                  trailing: DropdownButton<Locale>(
                    value: entity.language,
                    items: _languageItems(),
                    onChanged: (value) {
                      if (value != null) {
                        context.read<SettingsCubit>().changeLanguage(value);
                      }
                    },
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('Giao diện'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Light'),
                      Switch(
                        value: entity.themeMode == ThemeMode.dark,
                        onChanged: (isDark) {
                          context
                              .read<SettingsCubit>()
                              .changeTheme(isDark ? ThemeMode.dark : ThemeMode.light);
                        },
                      ),
                      const Text('Dark'),
                    ],
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Thông báo'),
                  trailing: Switch(
                    value: entity.notificationsEnabled,
                    onChanged: (enabled) {
                      context.read<SettingsCubit>().changeNotifications(enabled);
                    },
                  ),
                ),
              ),
              if (state is SettingsError)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
