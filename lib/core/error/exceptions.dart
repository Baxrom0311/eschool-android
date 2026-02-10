/// Custom exception turlari
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({this.message = 'Server xatoligi', this.statusCode});

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'Internet bilan aloqa yo\'q'});

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'Cache xatoligi'});

  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String message;

  const AuthException({this.message = 'Autentifikatsiya xatosi'});

  @override
  String toString() => 'AuthException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>>? errors;

  const ValidationException({
    this.message = 'Validatsiya xatoligi',
    this.errors,
  });

  @override
  String toString() => 'ValidationException: $message';
}
