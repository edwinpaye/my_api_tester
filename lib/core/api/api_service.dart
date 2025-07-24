// lib/core/api/api_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/api_request.dart';
import '../models/api_response.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  Future<ApiResponse> execute(ApiRequest request) async {
    final stopwatch = Stopwatch()..start();
    try {
      Response response;
      final options = Options(headers: request.headers);

      // Helper to try parsing body as JSON
      dynamic getBody() {
        if (request.body.isEmpty) return null;
        try {
          return jsonDecode(request.body);
        } catch (e) {
          return request.body; // Send as plain text if not valid JSON
        }
      }

      switch (request.method.toUpperCase()) {
        case 'POST':
          response = await _dio.post(request.url, data: getBody(), queryParameters: request.params, options: options);
          break;
        case 'PUT':
          response = await _dio.put(request.url, data: getBody(), queryParameters: request.params, options: options);
          break;
        case 'PATCH':
          response = await _dio.patch(request.url, data: getBody(), queryParameters: request.params, options: options);
          break;
        case 'DELETE':
          response = await _dio.delete(request.url, queryParameters: request.params, options: options);
          break;
        case 'GET':
        default:
          response = await _dio.get(request.url, queryParameters: request.params, options: options);
          break;
      }
      stopwatch.stop();

      String responseBody;
      try {
        responseBody = const JsonEncoder.withIndent('  ').convert(response.data);
      } catch (e) {
        responseBody = response.data.toString();
      }

      return ApiResponse(
        statusCode: response.statusCode ?? 0,
        body: responseBody,
        headers: response.headers.map,
        timeTaken: stopwatch.elapsed,
      );
    } on DioException catch (e) {
      stopwatch.stop();
      // Try to pretty-print error response if it's JSON
      String errorBody = e.response?.data?.toString() ?? e.message ?? "An unknown error occurred";
      try {
         errorBody = const JsonEncoder.withIndent('  ').convert(e.response?.data);
      } catch (_) {}

      return ApiResponse(
        statusCode: e.response?.statusCode ?? -1,
        body: errorBody,
        headers: e.response?.headers.map ?? {},
        timeTaken: stopwatch.elapsed,
      );
    }
  }
}