import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../error/failure.dart';
import '../../local/local_cache.dart';

class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: AppConstants.defaultApiBaseUrl,
  );

  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => debugPrint('[API] $obj'),
        ),
      );
    }
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    final cacheKey = '$path?${queryParameters.toString()}';
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      if (response.statusCode == 200 && response.data != null) {
        await LocalCache.saveCache(cacheKey, response.data);
        // Process offline queue on successful network call if any pending
        _flushOfflineQueue();
      }
      return response.data;
    } on DioException catch (e) {
      // Try serving from Hive cache
      final cached = LocalCache.getCache(cacheKey);
      if (cached != null) {
        return cached;
      }
      throw _handleDioError(e);
    } catch (e) {
      throw Failure(message: e.toString());
    }
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        // Enqueue offline write action
        await LocalCache.enqueueWrite({
          'method': 'POST',
          'path': path,
          'data': data,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
      throw _handleDioError(e);
    }
  }

  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        await LocalCache.enqueueWrite({
          'method': 'PUT',
          'path': path,
          'data': data,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
      throw _handleDioError(e);
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response.data;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        await LocalCache.enqueueWrite({
          'method': 'DELETE',
          'path': path,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
      throw _handleDioError(e);
    }
  }

  Future<void> _flushOfflineQueue() async {
    final queue = LocalCache.getQueue();
    if (queue.isEmpty) return;

    final remaining = <Map<String, dynamic>>[];
    for (final item in queue) {
      try {
        final method = item['method'] as String;
        final path = item['path'] as String;
        final data = item['data'];

        if (method == 'POST') {
          await _dio.post(path, data: data);
        } else if (method == 'PUT') {
          await _dio.put(path, data: data);
        } else if (method == 'DELETE') {
          await _dio.delete(path);
        }
      } catch (e) {
        remaining.add(item);
      }
    }

    if (remaining.isEmpty) {
      await LocalCache.clearQueue();
    }
  }

  Failure _handleDioError(DioException e) {
    if (e.response != null && e.response?.data is Map) {
      final errorMap = e.response?.data['error'];
      if (errorMap != null && errorMap is Map) {
        return Failure(
          code: errorMap['code'] ?? 'SERVER_ERROR',
          message: errorMap['message'] ?? 'An error occurred',
        );
      }
    }
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return const Failure(code: 'TIMEOUT', message: 'Connection timed out. Serving last synced data.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return const Failure(code: 'OFFLINE', message: 'Network connection unavailable. Showing cached data.');
    }
    return Failure(message: e.message ?? 'Network error occurred');
  }
}
