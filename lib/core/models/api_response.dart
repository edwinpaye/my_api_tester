// lib/core/models/api_response.dart
class ApiResponse {
  final int statusCode;
  final String body;
  final Map<String, dynamic> headers;
  final Duration timeTaken;

  const ApiResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
    required this.timeTaken,
  });
}