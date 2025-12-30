abstract final class ApiConstants {
  static const String baseUrl = 'https://rickandmortyapi.com/api';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
}

abstract final class Paths {
  static const String character = '/character';
  static const String location = '/location';
  static const String episode = '/episode';
}
