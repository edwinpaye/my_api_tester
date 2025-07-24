// lib/core/models/execution_result.dart
import 'dart:typed_data'; // For Uint8List
import 'api_response.dart';

/// A sealed class representing the outcome of an API request.
/// It can either be a text-based response or a binary file response.
sealed class ExecutionResult {}

class TextResult extends ExecutionResult {
  final ApiResponse response;
  TextResult(this.response);
}

class FileResult extends ExecutionResult {
  final Uint8List bytes;
  final String filename;
  FileResult(this.bytes, this.filename);
}