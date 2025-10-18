import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../core/constants.dart';
import '../data/datasources/remote/account_remote_datasource.dart';
import '../data/repositories/account_repository_impl.dart';
import '../domain/repositories/account_repository.dart';
import '../domain/repositories/auth_repository.dart';

// mock implementations (domain mock classes are imported from their own files)

final sl = GetIt.instance;

Future<void> init() async {
  try {
    // Dio configured per-flavor (use empty string if no url configured)
    final baseUrl = EnvConfig.baseUrls[currentFlavor] ?? '';
    final dio = Dio(BaseOptions(baseUrl: baseUrl));

    // Add simple logging interceptor (safe to add in dev)
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    // Register Dio and data sources only if not registered already
    if (!sl.isRegistered<Dio>()) {
      sl.registerLazySingleton<Dio>(() => dio);
    }

    if (!sl.isRegistered<FlutterSecureStorage>()) {
      sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
    }

    if (!sl.isRegistered<AccountRemoteDataSource>()) {
      // AccountRemoteDataSource depends on Dio; use the registered instance
      sl.registerLazySingleton<AccountRemoteDataSource>(() => AccountRemoteDataSource(dio: sl<Dio>()));
    }

    // Register repository implementation which uses the remote datasource
    if (!sl.isRegistered<AccountRepository>()) {
      sl.registerLazySingleton<AccountRepository>(() => AccountRepositoryImpl(remote: sl<AccountRemoteDataSource>()));
    }

    // Register mock or real AuthRepository depending on what's already available
    if (!sl.isRegistered<AuthRepository>()) {
      // For dev we use MockAuthRepository by default; production can override by calling register
      sl.registerLazySingleton<AuthRepository>(() => MockAuthRepository());
    }
  } catch (e, st) {
    // If DI init fails, make sure we log the error and leave the locator in a usable state
    // (do not rethrow to avoid killing runApp). The app's main() has a try/catch to show an error UI.
  // Use debugPrint so logs appear in logcat / console during debugging and avoid lint
  debugPrint('DI init failed: $e');
  debugPrint(st.toString());

    // Attempt minimal fallback registrations so app can show an error screen
    try {
      if (!sl.isRegistered<AuthRepository>()) {
        sl.registerLazySingleton<AuthRepository>(() => MockAuthRepository());
      }
      if (!sl.isRegistered<FlutterSecureStorage>()) {
        sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
      }
    } catch (_) {
      // swallow - we already logged the primary error; if even fallback fails there's little we can do
    }
  }
}
