// packages
import 'package:digital_bank_app/domain/repositories/account_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

// core
import 'core/di.dart' as di;
import 'core/constants.dart';
import 'core/theme.dart';
import 'presentation/pages/navigation_page.dart';

// login_page
import 'package:digital_bank_app/domain/repositories/auth_repository.dart';
import 'package:digital_bank_app/presentation/cubit/auth/login_cubit.dart';
import 'package:digital_bank_app/presentation/pages/auth/login_page.dart';

// import thêm
// settings_page
import 'domain/repositories/settings_repository.dart';
import 'presentation/cubit/settings/settings_cubit.dart';
import 'presentation/cubit/settings/settings_state.dart';
import 'presentation/pages/settings/settings_page.dart';

// notifications_page
import 'domain/repositories/notifications_repository.dart';
import 'presentation/cubit/notifications/notifications_cubit.dart';
import 'presentation/pages/notifications/notifications_page.dart';

// transaction_history_page
import 'domain/repositories/transaction_repository.dart';
import 'presentation/cubit/transactions/transaction_history_cubit.dart';
import 'presentation/pages/transactions/transaction_history_page.dart';

// transaction_history_page
import 'domain/repositories/transfer_repository.dart';
import 'presentation/cubit/transfer/transfer_cubit.dart';
import 'presentation/pages/transfer/transfer_page.dart';

// Mock localization delegate
class SimpleLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
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
          child: SingleChildScrollView(
              child: Text(
                  'DI initialization failed:\n\n${e.toString()}\n\n${st.toString()}')),
        ),
      ),
    ));
    return;
  }

  final repo = di.sl<AuthRepository>();
  final settingsRepo = di.sl<SettingsRepository>();
  final notificationsRepo = di.sl<NotificationsRepository>();
  final transactionRepo = di.sl<TransactionRepository>();
  final transferRepo = di.sl<TransferRepository>();
  final accountRepo = di.sl<AccountRepository>();

  // Surface uncaught Flutter errors on-screen (useful during debug / QA builds)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    // show exception text so the user/dev sees it instead of a black screen
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Startup error')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              SingleChildScrollView(child: Text(details.exceptionAsString())),
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
          BlocProvider(
              create: (_) =>
                  NotificationsCubit(notificationsRepo)..loadNotifications()),
          BlocProvider(
              create: (_) =>
                  TransactionHistoryCubit(transactionRepo)..initAndLoad()),
          BlocProvider(create: (_) => TransferCubit(transferRepo, accountRepo)),
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
          theme: themeMode == ThemeMode.light ? lightTheme : dartTheme,
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
                    create: (_) =>
                        SettingsCubit(di.sl<SettingsRepository>())..load(),
                    child: const SettingsPage(key: PageStorageKey('settings'))),
            '/notification': (_) => di.sl.isRegistered<NotificationsCubit>()
                ? BlocProvider.value(
                    value: di.sl<NotificationsCubit>(),
                    child: const NotificationsPage(
                        key: PageStorageKey('notification')))
                : BlocProvider(
                    create: (_) =>
                        NotificationsCubit(di.sl<NotificationsRepository>())
                          ..loadNotifications(),
                    child: const NotificationsPage(
                        key: PageStorageKey('notification')),
                  ),
            '/transactions': (_) => di.sl
                    .isRegistered<TransactionHistoryCubit>()
                ? BlocProvider.value(
                    value: di.sl<TransactionHistoryCubit>(),
                    child: const TransactionHistoryPage(
                        key: PageStorageKey('transaction_history')))
                : BlocProvider(
                    create: (_) =>
                        TransactionHistoryCubit(di.sl<TransactionRepository>())
                          ..initAndLoad(),
                    child: const TransactionHistoryPage(
                        key: PageStorageKey('transaction_history')),
                  ),
            '/transfer': (_) => di.sl.isRegistered<TransferCubit>()
                ? BlocProvider.value(
                    value: di.sl<TransferCubit>(),
                    child: const TransferPage(key: PageStorageKey('transfer')))
                : BlocProvider(
                    create: (_) => TransferCubit(di.sl<TransferRepository>(), di.sl<AccountRepository>()),
                    child: const TransferPage(key: PageStorageKey('transfer')),
                  ),
          },
        );
      },
    );
  }
}
