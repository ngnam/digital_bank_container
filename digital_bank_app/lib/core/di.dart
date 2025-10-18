import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants.dart';
import '../data/datasources/remote/account_remote_datasource.dart';
import '../data/repositories/account_repository_impl.dart';
import '../domain/repositories/account_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Dio configured per-flavor
  final baseUrl = EnvConfig.baseUrls[currentFlavor] ?? '';
  final dio = Dio(BaseOptions(baseUrl: baseUrl));

  // Add simple logging interceptor
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  // Register Dio and data sources
  sl.registerLazySingleton<Dio>(() => dio);
  // Register secure storage
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  sl.registerLazySingleton<AccountRemoteDataSource>(() => AccountRemoteDataSource(dio: sl<Dio>()));

  // Register repository implementation which uses the remote datasource
  sl.registerLazySingleton<AccountRepository>(() => AccountRepositoryImpl(remote: sl<AccountRemoteDataSource>()));
}
