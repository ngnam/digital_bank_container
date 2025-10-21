import 'package:digital_bank_app/domain/repositories/auth_repository.dart';
import 'package:digital_bank_app/presentation/cubit/auth/login_cubit.dart';
import 'package:digital_bank_app/presentation/pages/auth/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di.dart' as di;
import 'core/constants.dart';
import 'core/theme.dart';
import 'presentation/pages/navigation_page.dart';

// import thêm
import 'domain/repositories/settings_repository.dart';
import 'presentation/cubit/settings/settings_cubit.dart';
import 'presentation/cubit/settings/settings_state.dart';
import 'presentation/pages/settings/settings_page.dart';


// Mock localization delegate
class SimpleLocalizationsDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const SimpleLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['vi', 'en'].contains(locale.languageCode);

  @override
  Future<WidgetsLocalizations> load(Locale locale) async {
    return const DefaultWidgetsLocalizations();
  }

  @override
  bool shouldReload(LocalizationsDelegate<WidgetsLocalizations> old) => false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // set a default flavor for non-flavored entrypoints
  currentFlavor = Flavor.dev;

  try {
    await di.init();
  } catch (e, st) {
    // If DI fails, show a simple error UI so the device isn't left with a black screen.
    runApp(MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Initialization error')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(child: Text('DI initialization failed:\n\n${e.toString()}\n\n${st.toString()}')),
        ),
      ),
    ));
    return;
  }

  final repo = di.sl<AuthRepository>();
  final settingsRepo = di.sl<SettingsRepository>();

  // Surface uncaught Flutter errors on-screen (useful during debug / QA builds)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    // show exception text so the user/dev sees it instead of a black screen
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Startup error')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(child: Text(details.exceptionAsString())),
        ),
      ),
    );
  };

  // Also catch any uncaught zone errors and print them (can be expanded to show UI)
  runZonedGuarded(() {
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => LoginCubit(repo)),
          BlocProvider(create: (_) => SettingsCubit(settingsRepo)..load()),
        ],
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    // Print to console / logs so we can inspect on CI or via adb logcat
    // ignore: avoid_print
    print('Uncaught zone error: $error');
    // You could also push a UI notification here via a navigator key if desired
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final themeMode = state.entity.themeMode;
        final locale = state.entity.language;

        return MaterialApp(
          title: 'Digital Bank',
          theme: lightTheme,
          darkTheme: ThemeData.dark(),
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: const [
            SimpleLocalizationsDelegate(),
            DefaultWidgetsLocalizations.delegate,
            DefaultMaterialLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
          ],
          initialRoute: '/',
          routes: {
            '/': (_) => const LoginPage(key: PageStorageKey('login')),
            '/dashboard': (_) =>
                const NavigationPage(key: PageStorageKey('navigation')),
            '/settings': (_) => di.sl.isRegistered<SettingsCubit>()
                ? BlocProvider.value(
                    value: di.sl<SettingsCubit>(),
                    child: const SettingsPage(key: PageStorageKey('settings')))
                : BlocProvider(
                    create: (_) => SettingsCubit(di.sl<SettingsRepository>())..load(),
                    child: const SettingsPage(key: PageStorageKey('settings'))),
          },
        );
      },
    );
  }
}