// lib/core/models/api_request.dart
class ApiRequest {
  final String method;
  final String url;
  final Map<String, String> headers;
  final Map<String, String> params;
  final String body;

  const ApiRequest({
    required this.method,
    required this.url,
    required this.headers,
    required this.params,
    required this.body,
  });

  factory ApiRequest.empty() {
    return const ApiRequest(
      method: 'GET',
      url: 'https://jsonplaceholder.typicode.com/posts',
      headers: {'Content-Type': 'application/json'},
      params: {},
      body: '',
    );
  }

  ApiRequest copyWith({
    String? method,
    String? url,
    Map<String, String>? headers,
    Map<String, String>? params,
    String? body,
  }) {
    return ApiRequest(
      method: method ?? this.method,
      url: url ?? this.url,
      headers: headers ?? this.headers,
      params: params ?? this.params,
      body: body ?? this.body,
    );
  }
}