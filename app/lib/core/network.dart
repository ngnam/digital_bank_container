import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DioClient {
  final Dio dio;
  DioClient._(this.dio);

  static Future<DioClient> create({required String baseUrl}) async {
    final dio = Dio(BaseOptions(baseUrl: baseUrl));
    dio.interceptors.add(_AuthInterceptor());
    // Certificate pinning example
    dio.httpClientAdapter = await _createPinnedAdapter();
    return DioClient._(dio);
  }

  static Future<HttpClientAdapter> _createPinnedAdapter() async {
    // TODO: Implement certificate pinning logic here
    // For demo, return default adapter
    return IOHttpClientAdapter();
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: Add auth token logic
    super.onRequest(options, handler);
  }
}
