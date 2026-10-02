/// Domain-level error mapped from network / platform failures.
sealed class AppError {
  const AppError({
    required this.message,
    this.code,
    this.status,
    this.requestId,
    this.cause,
  });

  final String message;
  final String? code;
  final int? status;
  final String? requestId;
  final Object? cause;
}

final class NetworkAppError extends AppError {
  const NetworkAppError({
    required super.message,
    super.cause,
  });
}

final class TimeoutAppError extends AppError {
  const TimeoutAppError({
    required super.message,
    super.cause,
  });
}

final class CancelledAppError extends AppError {
  const CancelledAppError({
    required super.message,
    super.cause,
  });
}

final class ApiAppError extends AppError {
  const ApiAppError({
    required super.message,
    required super.code,
    required super.status,
    super.requestId,
    this.detail,
    this.title,
    super.cause,
  });

  final String? detail;
  final String? title;
}

final class UnknownAppError extends AppError {
  const UnknownAppError({
    required super.message,
    super.cause,
  });
}
