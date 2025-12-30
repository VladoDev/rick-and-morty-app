import 'package:dio/dio.dart';
import 'package:rick_and_morty_app/core/errors/app_exception.dart';

AppException mapDioError(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;

    if (status != null) {
      return AppException(
        "Request failed (HTTP $status)",
        cause: error.message,
      );
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return AppException("Timeout. Please try again.", cause: error);
      case DioExceptionType.connectionError:
        return AppException('No internet connection.', cause: error);
      case DioExceptionType.cancel:
        return AppException('Request cancelled.', cause: error);
      case DioExceptionType.badResponse:
        return AppException('Bad server response.', cause: error);
      case DioExceptionType.unknown:
        return AppException('Unexpected network error.', cause: error);
      case DioExceptionType.badCertificate:
        return AppException('Bad certificate error.', cause: error);
    }
  }
  return AppException('Unexpected error.', cause: error);
}
