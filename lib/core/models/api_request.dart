// // lib/core/models/api_request.dart
// class ApiRequest {
//   final String method;
//   final String url;
//   final Map<String, String> headers;
//   final Map<String, String> params;
//   final String body;

//   const ApiRequest({
//     required this.method,
//     required this.url,
//     required this.headers,
//     required this.params,
//     required this.body,
//   });

//   factory ApiRequest.empty() {
//     return const ApiRequest(
//       method: 'GET',
//       url: 'https://jsonplaceholder.typicode.com/posts',
//       headers: {'Content-Type': 'application/json'},
//       params: {},
//       body: '',
//     );
//   }

//   ApiRequest copyWith({
//     String? method,
//     String? url,
//     Map<String, String>? headers,
//     Map<String, String>? params,
//     String? body,
//   }) {
//     return ApiRequest(
//       method: method ?? this.method,
//       url: url ?? this.url,
//       headers: headers ?? this.headers,
//       params: params ?? this.params,
//       body: body ?? this.body,
//     );
//   }
// }

// // lib/core/models/api_request.dart

// // Import the 'convert' library to use JSON encoding and decoding.
// import 'dart:convert';

// /// Represents a single API request that can be saved and executed.
// ///
// /// This class is designed to be immutable. To modify an instance,
// /// use the `copyWith` method to create a new one with updated values.
// class ApiRequest {
//   /// The unique identifier from the SQLite database.
//   /// It is nullable because a new request that has not yet been saved
//   /// will not have an ID.
//   final int? id;

//   /// The HTTP method for the request (e.g., 'GET', 'POST').
//   final String method;

//   /// The URL endpoint for the request.
//   final String url;

//   /// A map of HTTP headers. Stored as a JSON string in the database.
//   final Map<String, String> headers;

//   /// A map of query parameters. Stored as a JSON string in the database.
//   final Map<String, String> params;

//   /// The request body, typically a JSON string.
//   final String body;

//   factory ApiRequest.newUnsaved() {
//     return ApiRequest(
//       method: 'GET',
//       url: '',
//       headers: {},
//       params: {},
//       body: '',
//     );
//   }

//   ApiRequest({
//     this.id,
//     required this.method,
//     required this.url,
//     required this.headers,
//     required this.params,
//     required this.body,
//   });

//   /// Creates a new `ApiRequest` instance with updated values.
//   ///
//   /// This is useful for immutability, allowing you to create a modified
//   /// copy of a request without changing the original instance.
//   ApiRequest copyWith({
//     int? id,
//     String? method,
//     String? url,
//     Map<String, String>? headers,
//     Map<String, String>? params,
//     String? body,
//   }) {
//     return ApiRequest(
//       id: id ?? this.id,
//       method: method ?? this.method,
//       url: url ?? this.url,
//       headers: headers ?? this.headers,
//       params: params ?? this.params,
//       body: body ?? this.body,
//     );
//   }

//   /// Converts this `ApiRequest` object into a `Map<String, dynamic>`.
//   ///
//   /// This format is required by the `sqflite` package for database operations
//   /// like inserting and updating records. The `headers` and `params` maps
//   /// are serialized into JSON strings for storage in `TEXT` columns.
//   Map<String, dynamic> toDbMap() {
//     return {
//       'id': id,
//       'method': method,
//       'url': url,
//       'headers': jsonEncode(headers), // Encode map to JSON string
//       'params': jsonEncode(params),   // Encode map to JSON string
//       'body': body,
//     };
//   }

//   /// Creates an `ApiRequest` instance from a `Map<String, dynamic>`.
//   ///
//   /// This factory constructor is used to deserialize the data retrieved
//   /// from the SQLite database back into a usable Dart object. It decodes
//   /// the `headers` and `params` from their JSON string representation.
//   factory ApiRequest.fromDbMap(Map<String, dynamic> map) {
//     return ApiRequest(
//       id: map['id'] as int?,
//       method: map['method'] as String,
//       url: map['url'] as String,
//       // Decode JSON string back to a Dart map
//       headers: Map<String, String>.from(jsonDecode(map['headers'] as String)),
//       params: Map<String, String>.from(jsonDecode(map['params'] as String)),
//       body: map['body'] as String,
//     );
//   }
// }

// lib/core/models/api_request.dart
import 'dart:convert';
import 'package:file_picker/file_picker.dart'; // Import file_picker

enum BodyType { none, json, formData }

class ApiRequest {
  final int? id;
  final String method;
  final String url;
  final Map<String, String> headers;
  final Map<String, String> params;
  
  // New properties for advanced body handling
  final BodyType bodyType;
  final String body; // Used for JSON
  final Map<String, String> formDataText; // For text fields in form-data
  final Map<String, PlatformFile> formDataFiles; // For files in form-data

  ApiRequest({
    this.id,
    required this.method,
    required this.url,
    required this.headers,
    required this.params,
    this.bodyType = BodyType.none,
    this.body = '',
    this.formDataText = const {},
    this.formDataFiles = const {},
  });
  
  factory ApiRequest.newUnsaved() {
    return ApiRequest(
      method: 'GET',
      url: 'https://jsonplaceholder.typicode.com/posts',
      headers: {},
      params: {},
    );
  }

  ApiRequest copyWith({
    int? id,
    String? method,
    String? url,
    Map<String, String>? headers,
    Map<String, String>? params,
    BodyType? bodyType,
    String? body,
    Map<String, String>? formDataText,
    Map<String, PlatformFile>? formDataFiles,
  }) {
    return ApiRequest(
      id: id ?? this.id,
      method: method ?? this.method,
      url: url ?? this.url,
      headers: headers ?? this.headers,
      params: params ?? this.params,
      bodyType: bodyType ?? this.bodyType,
      body: body ?? this.body,
      formDataText: formDataText ?? this.formDataText,
      formDataFiles: formDataFiles ?? this.formDataFiles,
    );
  }

  // Updated to handle new properties
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'method': method,
      'url': url,
      'headers': jsonEncode(headers),
      'params': jsonEncode(params),
      'body': body,
      'bodyType': bodyType.index, // Store enum as integer
      'formDataText': jsonEncode(formDataText),
      // Note: We don't save files to DB, only their paths if needed.
      // For simplicity, we'll just ignore them for persistence.
    };
  }

  factory ApiRequest.fromDbMap(Map<String, dynamic> map) {
    return ApiRequest(
      id: map['id'],
      method: map['method'],
      url: map['url'],
      headers: Map<String, String>.from(jsonDecode(map['headers'])),
      params: Map<String, String>.from(jsonDecode(map['params'])),
      body: map['body'],
      bodyType: BodyType.values[map['bodyType'] ?? BodyType.json.index],
      formDataText: Map<String, String>.from(jsonDecode(map['formDataText'] ?? '{}')),
    );
  }
}