import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hafidz_app/core/errors/app_error.dart';

/// Maps [DioException] / RFC 7807 problem+json into [AppError].
abstract final class ErrorMapper {
  static AppError fromDio(DioException error, {String? fallbackMessage}) {
    switch (error.type) {
      case DioExceptionType.cancel:
        return CancelledAppError(
          message: fallbackMessage ?? 'Request cancelled',
          cause: error,
        );
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutAppError(
          message: fallbackMessage ?? 'Request timed out',
          cause: error,
        );
      case DioExceptionType.connectionError:
        return NetworkAppError(
          message: fallbackMessage ?? 'Unable to reach the server',
          cause: error,
        );
      case DioExceptionType.badResponse:
        return _fromResponse(error.response, cause: error);
      case DioExceptionType.badCertificate:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.unknown:
        if (error.error is AppError) {
          return error.error! as AppError;
        }
        return UnknownAppError(
          message: fallbackMessage ?? 'Unexpected error',
          cause: error,
        );
    }
  }

  static AppError fromObject(Object error, {String? fallbackMessage}) {
    if (error is AppError) return error;
    if (error is DioException) {
      return fromDio(error, fallbackMessage: fallbackMessage);
    }
    return UnknownAppError(
      message: fallbackMessage ?? error.toString(),
      cause: error,
    );
  }

  static AppError _fromResponse(Response<dynamic>? response, {Object? cause}) {
    final status = response?.statusCode;
    final data = response?.data;
    final problem = _parseProblem(data);

    if (problem != null) {
      return ApiAppError(
        message: problem.detail ?? problem.title ?? 'API error',
        code: problem.code,
        status: problem.status ?? status,
        requestId: problem.requestId,
        detail: problem.detail,
        title: problem.title,
        cause: cause,
      );
    }

    return ApiAppError(
      message: 'HTTP ${status ?? 'error'}',
      code: _codeForStatus(status),
      status: status,
      cause: cause,
    );
  }

  static _Problem? _parseProblem(Object? data) {
    Map<String, dynamic>? map;
    if (data is Map<String, dynamic>) {
      map = data;
    } else if (data is Map) {
      map = Map<String, dynamic>.from(data);
    } else if (data is String && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          map = decoded;
        } else if (decoded is Map) {
          map = Map<String, dynamic>.from(decoded);
        }
      } on FormatException {
        return null;
      }
    }
    if (map == null) return null;

    final code = map['code'] as String?;
    final title = map['title'] as String?;
    if (code == null && title == null) return null;

    return _Problem(
      type: map['type'] as String?,
      title: title,
      status: map['status'] as int?,
      detail: map['detail'] as String?,
      code: code ?? 'VALIDATION_ERROR',
      requestId: map['request_id'] as String?,
    );
  }

  static String _codeForStatus(int? status) {
    return switch (status) {
      404 => 'NOT_FOUND',
      429 => 'RATE_LIMITED',
      503 => 'UPSTREAM_UNAVAILABLE',
      _ => 'VALIDATION_ERROR',
    };
  }
}

class _Problem {
  const _Problem({
    required this.code,
    this.type,
    this.title,
    this.status,
    this.detail,
    this.requestId,
  });

  final String? type;
  final String? title;
  final int? status;
  final String? detail;
  final String code;
  final String? requestId;
}
