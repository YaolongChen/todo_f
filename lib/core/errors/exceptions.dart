class ServerException({
  required final String message,
  final int? statusCode,
  final int? code,
}) implements Exception;

class NetworkException({final String message = "No internet!"})
    implements Exception;

class CacheException({final String message = "Cache error"})
    implements Exception;
