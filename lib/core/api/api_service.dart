// // lib/core/api/api_service.dart
// import 'dart:convert';
// import 'package:dio/dio.dart';
// import '../models/api_request.dart';
// import '../models/api_response.dart';

// class ApiService {
//   final Dio _dio;

//   ApiService(this._dio);

//   Future<ApiResponse> execute(ApiRequest request) async {
//     final stopwatch = Stopwatch()..start();
//     try {
//       Response response;
//       final options = Options(headers: request.headers);

//       // Helper to try parsing body as JSON
//       dynamic getBody() {
//         if (request.body.isEmpty) return null;
//         try {
//           return jsonDecode(request.body);
//         } catch (e) {
//           return request.body; // Send as plain text if not valid JSON
//         }
//       }

//       switch (request.method.toUpperCase()) {
//         case 'POST':
//           response = await _dio.post(request.url, data: getBody(), queryParameters: request.params, options: options);
//           break;
//         case 'PUT':
//           response = await _dio.put(request.url, data: getBody(), queryParameters: request.params, options: options);
//           break;
//         case 'PATCH':
//           response = await _dio.patch(request.url, data: getBody(), queryParameters: request.params, options: options);
//           break;
//         case 'DELETE':
//           response = await _dio.delete(request.url, queryParameters: request.params, options: options);
//           break;
//         case 'GET':
//         default:
//           response = await _dio.get(request.url, queryParameters: request.params, options: options);
//           break;
//       }
//       stopwatch.stop();

//       String responseBody;
//       try {
//         responseBody = const JsonEncoder.withIndent('  ').convert(response.data);
//       } catch (e) {
//         responseBody = response.data.toString();
//       }

//       return ApiResponse(
//         statusCode: response.statusCode ?? 0,
//         body: responseBody,
//         headers: response.headers.map,
//         timeTaken: stopwatch.elapsed,
//       );
//     } on DioException catch (e) {
//       stopwatch.stop();
//       // Try to pretty-print error response if it's JSON
//       String errorBody = e.response?.data?.toString() ?? e.message ?? "An unknown error occurred";
//       try {
//          errorBody = const JsonEncoder.withIndent('  ').convert(e.response?.data);
//       } catch (_) {}

//       return ApiResponse(
//         statusCode: e.response?.statusCode ?? -1,
//         body: errorBody,
//         headers: e.response?.headers.map ?? {},
//         timeTaken: stopwatch.elapsed,
//       );
//     }
//   }
// }

// // lib/core/api/api_service.dart
// import 'dart:convert';
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';
// import '../models/api_request.dart';
// import '../models/api_response.dart';

// class ApiService {
//   final Dio _dio;
//   ApiService(this._dio);

//   Future<ApiResponse> executeRequest(ApiRequest request) async {
//     final stopwatch = Stopwatch()..start();
//     try {
//       Response response;
//       final options = Options(headers: request.headers);
//       dynamic data = request.body.isEmpty ? null : jsonDecode(request.body);

//       switch (request.method.toUpperCase()) {
//         case 'POST':
//           response = await _dio.post(request.url, data: data, queryParameters: request.params, options: options);
//           break;
//         // Add other methods like PUT, PATCH, DELETE here
//         default:
//           response = await _dio.get(request.url, queryParameters: request.params, options: options);
//           break;
//       }
//       stopwatch.stop();

//       // Try to pretty-print the JSON body
//       String responseBody;
//       try {
//         responseBody = const JsonEncoder.withIndent('  ').convert(response.data);
//       } catch (e) {
//         responseBody = response.data.toString();
//       }

//       return ApiResponse(
//         statusCode: response.statusCode ?? 0,
//         body: responseBody,
//         headers: response.headers.map,
//         timeTaken: stopwatch.elapsed,
//       );
//     } on DioException catch (e) {
//       stopwatch.stop();
//       String errorBody = e.response?.data?.toString() ?? e.message ?? "An unknown error occurred";
//       return ApiResponse(
//         statusCode: e.response?.statusCode ?? -1,
//         body: errorBody,
//         headers: e.response?.headers.map ?? {},
//         timeTaken: stopwatch.elapsed,
//       );
//     }
//   }
// }

// // lib/core/api/api_service.dart
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:dio/dio.dart';
// import 'package:path/path.dart' as p;
// import '../models/api_request.dart';
// import '../models/api_response.dart';
// import '../models/execution_result.dart';

// class ApiService {
//   final Dio _dio;
//   ApiService(this._dio);

//   Future<ExecutionResult> executeRequest(ApiRequest request) async {
//     final stopwatch = Stopwatch()..start();
//     try {
//       // Set common options, including requesting raw bytes for smart handling
//       final options = Options(
//         headers: request.headers,
//         responseType: ResponseType.bytes,
//       );

//       // --- DYNAMICALLY PREPARE THE REQUEST BODY ---
//       // This logic now correctly handles all body types from our model.
//       dynamic data;
//       switch (request.bodyType) {
//         case BodyType.json:
//           if (request.body.isNotEmpty) {
//             try {
//               data = jsonDecode(request.body);
//             } catch (e) {
//               // If JSON is malformed, send as plain text
//               data = request.body;
//             }
//           }
//           break;
//         case BodyType.formData:
//           final textFields =
//               request.formDataText.map((key, value) => MapEntry(key, value));
//           final fileFields = request.formDataFiles.map((key, file) =>
//               MapEntry(
//                   key, MultipartFile.fromFileSync(file.path!, filename: file.name)));
//           data = FormData.fromMap({...textFields, ...fileFields});
//           break;
//         case BodyType.none:
//           data = null;
//           break;
//       }

//       // --- USE A SWITCH TO CALL THE CORRECT DIO METHOD ---
//       // This is the core fix.
//       final Response response;
//       switch (request.method.toUpperCase()) {
//         case 'POST':
//           response = await _dio.post(
//             request.url,
//             data: data,
//             queryParameters: request.params,
//             options: options,
//           );
//           break;
//         case 'PUT':
//           response = await _dio.put(
//             request.url,
//             data: data,
//             queryParameters: request.params,
//             options: options,
//           );
//           break;
//         case 'PATCH':
//           response = await _dio.patch(
//             request.url,
//             data: data,
//             queryParameters: request.params,
//             options: options,
//           );
//           break;
//         case 'DELETE':
//           response = await _dio.delete(
//             request.url,
//             data: data, // Dio supports a body for DELETE, though uncommon
//             queryParameters: request.params,
//             options: options,
//           );
//           break;
//         case 'GET':
//         default:
//           response = await _dio.get(
//             request.url,
//             queryParameters: request.params,
//             options: options,
//           );
//           break;
//       }
//       stopwatch.stop();

//       // --- Smart response handling logic (this part was already correct) ---
//       final headers = response.headers.map;
//       final contentType = headers['content-type']?.first ?? '';
//       final contentDisposition = headers['content-disposition']?.first ?? '';

//       final filenameMatch = RegExp('filename="(.+?)"').firstMatch(contentDisposition);
//       if (filenameMatch != null) {
//         final filename = filenameMatch.group(1)!;
//         return FileResult(response.data as Uint8List, filename);
//       }

//       if (contentType.startsWith('image/') ||
//           contentType.startsWith('video/') ||
//           contentType.startsWith('audio/') ||
//           contentType == 'application/pdf' ||
//           contentType == 'application/zip' ||
//           contentType == 'application/octet-stream') {
//         final filename = p.basename(request.url);
//         return FileResult(response.data as Uint8List, filename.isNotEmpty ? filename : 'download');
//       }

//       final responseBodyString = utf8.decode(response.data);
//       String prettyBody;
//       try {
//         prettyBody = const JsonEncoder.withIndent('  ').convert(jsonDecode(responseBodyString));
//       } catch (e) {
//         prettyBody = responseBodyString;
//       }

//       final apiResponse = ApiResponse(
//         statusCode: response.statusCode ?? 0,
//         body: prettyBody,
//         headers: headers,
//         timeTaken: stopwatch.elapsed,
//       );
//       return TextResult(apiResponse);

//     } on DioException catch (e) {
//       stopwatch.stop();
//       String errorBody = e.message ?? "An unknown error occurred";
//       if (e.response?.data is List<int>) {
//         try {
//           errorBody = utf8.decode(e.response!.data);
//         } catch (_) {
//           // If decoding fails, just show the raw error
//           errorBody = e.response!.data.toString();
//         }
//       }
//       final apiResponse = ApiResponse(
//         statusCode: e.response?.statusCode ?? -1,
//         body: errorBody,
//         headers: e.response?.headers.map ?? {},
//         timeTaken: stopwatch.elapsed,
//       );
//       return TextResult(apiResponse);
//     }
//   }
// }
// lib/core/api/api_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import '../models/api_request.dart';
import '../models/api_response.dart';
import '../models/execution_result.dart';

class ApiService {
  final Dio _dio;
  ApiService(this._dio);

  // --- THIS IS THE DEFINITIVE, ROBUST ERROR PARSER ---
  /// Safely handles ANY data type from a DioException response.
  /// The order of checks is critical to avoid type ambiguity bugs.
  String _parseErrorBody(dynamic data) {
    if (data == null) return "[App Notice]: No error body was returned by the server.";

    // Priority 1: Handle raw bytes FIRST. This is the most common raw format.
    if (data is List<int>) {
      try {
        // Attempt to decode the bytes as a UTF-8 string.
        final decodedString = utf8.decode(data);
        // Now, try to pretty-print that string if it's JSON.
        try {
          return const JsonEncoder.withIndent('  ').convert(jsonDecode(decodedString));
        } catch (_) {
          // If not JSON, it's plain text (like an HTML error page).
          return decodedString;
        }
      } catch (_) {
        // If decoding fails, it's truly binary data (e.g., a broken image).
        return "[App Notice]: Received binary data in the error response that is not valid text.";
      }
    }

    // Priority 2: Handle if dio has already parsed it as a Map or List.
    if (data is Map || data is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(data);
      } catch (_) {
        return data.toString();
      }
    }

    // Priority 3: Handle if it's already a string.
    if (data is String) {
      try {
        // Check if the string itself is valid JSON.
        return const JsonEncoder.withIndent('  ').convert(jsonDecode(data));
      } catch (_) {
        // Not JSON, so return the string as-is.
        return data;
      }
    }

    // Final fallback for any other unexpected type.
    return data.toString();
  }

  Future<ExecutionResult> executeRequest(ApiRequest request) async {
    final stopwatch = Stopwatch()..start();
    try {
      final options = Options(headers: request.headers, responseType: ResponseType.bytes);
      dynamic data;
      switch (request.bodyType) {
        case BodyType.json:
          if (request.body.isNotEmpty) { try { data = jsonDecode(request.body); } catch (e) { data = request.body; } }
          break;
        case BodyType.formData:
          final textFields = request.formDataText.map((key, value) => MapEntry(key, value));
          final fileFields = request.formDataFiles.map((key, file) => MapEntry(key, MultipartFile.fromFileSync(file.path!, filename: file.name)));
          data = FormData.fromMap({...textFields, ...fileFields});
          break;
        case BodyType.none:
          data = null;
          break;
      }
      final Response response;
      switch (request.method.toUpperCase()) {
        case 'POST': response = await _dio.post(request.url, data: data, queryParameters: request.params, options: options); break;
        case 'PUT': response = await _dio.put(request.url, data: data, queryParameters: request.params, options: options); break;
        case 'PATCH': response = await _dio.patch(request.url, data: data, queryParameters: request.params, options: options); break;
        case 'DELETE': response = await _dio.delete(request.url, data: data, queryParameters: request.params, options: options); break;
        default: response = await _dio.get(request.url, queryParameters: request.params, options: options); break;
      }
      stopwatch.stop();
      final headers = response.headers.map;
      
      final contentDisposition = headers['content-disposition']?.first ?? '';
      final contentType = headers['content-type']?.first ?? '';
      final filenameMatch = RegExp('filename="(.+?)"').firstMatch(contentDisposition);
      if (filenameMatch != null) {
        return FileResult(response.data as Uint8List, filenameMatch.group(1)!);
      }
      if (contentType.startsWith('image/') || contentType.startsWith('video/') || contentType.startsWith('audio/') || contentType == 'application/pdf' || contentType == 'application/zip' || contentType == 'application/octet-stream') {
        final filename = p.basename(request.url);
        return FileResult(response.data as Uint8List, filename.isNotEmpty ? filename : 'download.bin');
      }
      
      String responseBodyString;
      try {
        responseBodyString = utf8.decode(response.data as Uint8List);
      } on FormatException {
        responseBodyString = "[App Notice]: Response could not be displayed as text because it contains non-UTF-8 characters. The server may have sent a binary file without the correct 'Content-Type' or 'Content-Disposition' headers.";
      }
      
      String prettyBody;
      try {
        prettyBody = const JsonEncoder.withIndent('  ').convert(jsonDecode(responseBodyString));
      } catch (_) {
        prettyBody = responseBodyString;
      }
      
      final apiResponse = ApiResponse(statusCode: response.statusCode ?? 0, body: prettyBody, headers: headers, timeTaken: stopwatch.elapsed);
      return TextResult(apiResponse);

    } on DioException catch (e) {
      // The DioException block now correctly uses the new robust parser.
      stopwatch.stop();
      if (e.response == null) {
        final apiResponse = ApiResponse(statusCode: -1, body: e.message ?? 'Network Error', headers: {}, timeTaken: stopwatch.elapsed);
        return TextResult(apiResponse);
      }
      final response = e.response!;
      final String errorBody = _parseErrorBody(response.data);
      final apiResponse = ApiResponse(statusCode: response.statusCode ?? 0, body: errorBody, headers: response.headers.map, timeTaken: stopwatch.elapsed);
      return TextResult(apiResponse);
    }
  }
}