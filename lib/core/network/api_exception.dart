class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool expired;
  final dynamic data;

  ApiException(
    this.message, {
    this.statusCode,
    this.expired = false,
    this.data,
  });

  @override
  String toString() => message;
}
