import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hafidz_app/core/device/device_id_provider.dart';
import 'package:hafidz_app/core/i18n/locale_provider.dart';

/// Compile-time base URL: `--dart-define=API_BASE_URL=http://10.0.2.2:8000`
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);

/// Matches pubspec.yaml version; override via `--dart-define=APP_VERSION=…`.
const appVersion = String.fromEnvironment(
  'APP_VERSION',
  defaultValue: '1.0.0+1',
);

final dioProvider = Provider<Dio>((ref) {
  final deviceId = ref.watch(deviceIdProvider);
  final locale = ref.watch(localeProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        Headers.acceptHeader: 'application/json',
        'X-Device-Id': deviceId,
        'Accept-Language': locale.languageCode,
        'X-App-Version': appVersion,
      },
    ),
  );
  ref.onDispose(() => dio.close(force: true));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['X-Device-Id'] = deviceId;
        options.headers['Accept-Language'] = locale.languageCode;
        options.headers['X-App-Version'] = appVersion;
        handler.next(options);
      },
    ),
  );

  return dio;
});
