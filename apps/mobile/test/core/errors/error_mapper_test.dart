import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hafidz_app/core/errors/app_error.dart';
import 'package:hafidz_app/core/errors/error_mapper.dart';

void main() {
  group('ErrorMapper', () {
    test('maps connection timeout to TimeoutAppError', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/v1/health'),
        type: DioExceptionType.connectionTimeout,
      );

      final mapped = ErrorMapper.fromDio(error);

      expect(mapped, isA<TimeoutAppError>());
    });

    test('maps connection error to NetworkAppError', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/v1/health'),
        type: DioExceptionType.connectionError,
      );

      final mapped = ErrorMapper.fromDio(error);

      expect(mapped, isA<NetworkAppError>());
    });

    test('maps cancel to CancelledAppError', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/v1/health'),
        type: DioExceptionType.cancel,
      );

      final mapped = ErrorMapper.fromDio(error);

      expect(mapped, isA<CancelledAppError>());
    });

    test('maps RFC 7807 problem+json to ApiAppError', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/v1/voice/detect'),
        type: DioExceptionType.badResponse,
        response: Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/v1/voice/detect'),
          statusCode: 429,
          data: {
            'type': 'about:blank',
            'title': 'Too Many Requests',
            'status': 429,
            'detail': 'Voice detect rate limit exceeded',
            'code': 'RATE_LIMITED',
            'request_id': 'req_123',
          },
        ),
      );

      final mapped = ErrorMapper.fromDio(error);

      expect(mapped, isA<ApiAppError>());
      final api = mapped as ApiAppError;
      expect(api.code, 'RATE_LIMITED');
      expect(api.status, 429);
      expect(api.requestId, 'req_123');
      expect(api.detail, 'Voice detect rate limit exceeded');
    });

    test('maps bare HTTP status without problem body', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/v1/quran/ayah/999:1'),
        type: DioExceptionType.badResponse,
        response: Response<String>(
          requestOptions: RequestOptions(path: '/v1/quran/ayah/999:1'),
          statusCode: 404,
          data: 'not found',
        ),
      );

      final mapped = ErrorMapper.fromDio(error);

      expect(mapped, isA<ApiAppError>());
      expect((mapped as ApiAppError).code, 'NOT_FOUND');
      expect(mapped.status, 404);
    });
  });
}
