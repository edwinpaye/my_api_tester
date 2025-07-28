// // lib/core/providers/app_providers.dart
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../database/database_service.dart';
// import '../models/api_request.dart';
// import 'package:dio/dio.dart';
// import '../api/api_service.dart';
// import '../models/api_response.dart';
// import 'package:file_picker/file_picker.dart';
// import 'dart:io';
// import 'package:open_file_plus/open_file_plus.dart';
// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';
// import 'dart:typed_data';
// import '../models/execution_result.dart'; // Import the new sealed class

// // --- Core Providers ---
// final navigationIndexProvider = StateProvider<int>((ref) => 0);
// final databaseProvider = Provider<DatabaseService>((ref) => DatabaseService.instance);
// final requestsProvider = FutureProvider.autoDispose<List<ApiRequest>>((ref) async {
//   final dbService = ref.watch(databaseProvider);
//   return dbService.getRequests();
// });

// // --- State Notifier for the active request form ---
// final activeRequestProvider =
//     StateNotifierProvider.autoDispose<ActiveRequestNotifier, ApiRequest>((ref) {
//   return ActiveRequestNotifier();
// });

// class ActiveRequestNotifier extends StateNotifier<ApiRequest> {
//   ActiveRequestNotifier() : super(ApiRequest.newUnsaved());

//   void loadRequest(ApiRequest request) {
//     state = request;
//   }

//   void newRequest() {
//     state = ApiRequest.newUnsaved();
//   }

//   void updateUrl(String url) => state = state.copyWith(url: url);
//   void updateMethod(String method) => state = state.copyWith(method: method);
//   void updateBody(String body) => state = state.copyWith(body: body);

//   void _updateMap({
//     required Map<String, String> map,
//     required int index,
//     required String key,
//     required String value,
//     required Function(Map<String, String>) onUpdate,
//   }) {
//     final entries = map.entries.toList();
//     if (index >= entries.length) return;
//     final oldEntry = entries[index];
    
//     // --- THIS IS THE CORRECTED PART ---
//     // Instead of Map.from(map), we use Map.of(map) which preserves the type,
//     // or we can be explicit with Map<String, String>.from(map).
//     // Map.of is generally cleaner.
//     final newMap = Map.of(map);
//     // --- END OF CORRECTION ---

//     newMap.remove(oldEntry.key);
//     newMap[key] = value;
//     onUpdate(newMap);
//   }

//   void addHeader() {
//     state = state.copyWith(headers: {...state.headers, '': ''});
//   }

//   void removeHeader(int index) {
//     final entries = state.headers.entries.toList();
//     if (index >= entries.length) return;
//     final newHeaders = Map.of(state.headers)..remove(entries[index].key);
//     state = state.copyWith(headers: newHeaders);
//   }

//   void updateHeader(int index, {String? key, String? value}) {
//     final entries = state.headers.entries.toList();
//     if (index >= entries.length) return;
//     final oldEntry = entries[index];
//     _updateMap(
//       map: state.headers,
//       index: index,
//       key: key ?? oldEntry.key,
//       value: value ?? oldEntry.value,
//       onUpdate: (newMap) => state = state.copyWith(headers: newMap),
//     );
//   }

//   void addParam() {
//     state = state.copyWith(params: {...state.params, '': ''});
//   }

//   void removeParam(int index) {
//     final entries = state.params.entries.toList();
//     if (index >= entries.length) return;
//     final newParams = Map.of(state.params)..remove(entries[index].key);
//     state = state.copyWith(params: newParams);
//   }

//   void updateParam(int index, {String? key, String? value}) {
//     final entries = state.params.entries.toList();
//     if (index >= entries.length) return;
//     final oldEntry = entries[index];
//     _updateMap(
//       map: state.params,
//       index: index,
//       key: key ?? oldEntry.key,
//       value: value ?? oldEntry.value,
//       onUpdate: (newMap) => state = state.copyWith(params: newMap),
//     );
//   }

//   void updateBodyType(BodyType type) {
//     state = state.copyWith(bodyType: type);
//   }

//   void addFormDataText() {
//     state = state.copyWith(formDataText: {...state.formDataText, '': ''});
//   }

//   void updateFormDataText(int index, {String? key, String? value}) {
//     // Similar logic to _updateMap, but for formDataText
//   }
  
//   void removeFormDataText(int index) {
//     // Similar logic to removeHeader, but for formDataText
//   }

//   void addFormDataFile(String key, PlatformFile file) {
//     state = state.copyWith(formDataFiles: {...state.formDataFiles, key: file});
//   }
  
//   void removeFormDataFile(String key) {
//     final newFiles = Map.of(state.formDataFiles)..remove(key);
//     state = state.copyWith(formDataFiles: newFiles);
//   }
// }

// // 1. Provider for the Dio instance
// final dioProvider = Provider<Dio>((ref) => Dio());

// // 2. Provider for our ApiService
// final apiServiceProvider = Provider<ApiService>((ref) {
//   return ApiService(ref.watch(dioProvider));
// });

// // 3. Provider to hold the state of the API response
// final responseStateProvider = StateProvider.autoDispose<AsyncValue<ExecutionResult>?>((ref) {
//   // Default to null, meaning no request has been sent yet
//   return null;
// });

// // 4. Provider to trigger the API call
// // final sendRequestProvider = Provider.autoDispose<Future<void> Function()>((ref) {
// //   return () async {
// //     // Set state to loading
// //     ref.read(responseStateProvider.notifier).state = const AsyncValue.loading();
    
// //     final apiService = ref.read(apiServiceProvider);
// //     final request = ref.read(activeRequestProvider);

// //     // Execute and update state with data or error
// //     final result = await AsyncValue.guard(() => apiService.executeRequest(request));
// //     ref.read(responseStateProvider.notifier).state = result;
// //   };
// // });
// final sendRequestProvider = Provider.autoDispose<Future<void> Function()>((ref) {
//   return () async {
//     ref.read(responseStateProvider.notifier).state = const AsyncValue.loading();
//     final apiService = ref.read(apiServiceProvider);
//     final request = ref.read(activeRequestProvider);
//     final result = await AsyncValue.guard(() => apiService.executeRequest(request));
//     ref.read(responseStateProvider.notifier).state = result;
//   };
// });

// final downloadProvider = Provider.autoDispose<Future<void> Function(String)>((ref) {
//   return (url) async {
//     final apiService = ref.read(apiServiceProvider);
//     await apiService.downloadFile(url);
//   };
// });

// // --- NEW PROVIDER TO SAVE RESPONSE BODY ---
// // final saveResponseBodyProvider = Provider.autoDispose<Future<void> Function(String, String)>((ref) {
// //   /// Takes the response body string and a suggested filename.
// //   return (body, filename) async {
// //     final dir = await getDownloadsDirectory();
// //     if (dir == null) {
// //       throw Exception('Could not get downloads directory.');
// //     }

// //     // Sanitize filename to avoid issues
// //     final safeFilename = filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
// //     final savePath = p.join(dir.path, safeFilename.isNotEmpty ? safeFilename : 'response.txt');
    
// //     final file = File(savePath);
// //     // Write the string content to the file
// //     await file.writeAsString(body);
// //     // Open the saved file
// //     await OpenFile.open(savePath);
// //   };
// // });

// final saveResponseBodyProvider = Provider.autoDispose<
//     // The provider now accepts the body string and the entire headers map
//     Future<void> Function(String, Map<String, dynamic>)>((ref) {

//   /// Takes the response body string and the response headers.
//   return (body, headers) async {
//     final dir = await getDownloadsDirectory();
//     if (dir == null) {
//       throw Exception('Could not get downloads directory.');
//     }

//     // --- NEW FILENAME PARSING LOGIC ---
//     String getFilename() {
//       // 1. Check for Content-Disposition header
//       final dispositionHeader = headers['content-disposition'] as List<String>?;
//       if (dispositionHeader != null && dispositionHeader.isNotEmpty) {
//         // A typical header is: 'attachment; filename="example.json"'
//         final disposition = dispositionHeader.first;
//         final filenameRegex = RegExp('filename="(.+?)"');
//         final match = filenameRegex.firstMatch(disposition);
//         if (match != null && match.groupCount > 0) {
//           // Return the captured filename
//           return match.group(1)!;
//         }
//       }

//       // 2. Fallback: use the active request URL (as before)
//       final request = ref.read(activeRequestProvider);
//       if (request.url.isNotEmpty) {
//         return '${p.basename(request.url)}.json';
//       }

//       // 3. Final fallback
//       return 'response.json';
//     }
//     // --- END FILENAME PARSING LOGIC ---

//     final filename = getFilename();
//     // Sanitize filename to prevent path traversal issues
//     final safeFilename = filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
//     final savePath = p.join(dir.path, safeFilename);
    
//     final file = File(savePath);
//     await file.writeAsString(body);
//     await OpenFile.open(savePath);
//   };
// });

// // --- NEW PROVIDER FOR THE "SEND AND DOWNLOAD" ACTION ---
// final sendAndDownloadProvider = Provider.autoDispose<Future<void> Function()>((ref) {
//   return () async {
//     final apiService = ref.read(apiServiceProvider);
//     final request = ref.read(activeRequestProvider);

//     if (request.url.isEmpty) {
//       throw Exception('URL cannot be empty.');
//     }
    
//     // This will throw an exception on failure, which the UI can catch.
//     await apiService.executeAndDownload(request);
//   };
// });

// // --- NEW PROVIDER TO SAVE FILE BYTES ---
// final saveFileProvider = Provider.autoDispose<Future<void> Function(Uint8List, String)>((ref) {
//   return (bytes, filename) async {
//     final dir = await getDownloadsDirectory();
//     if (dir == null) throw Exception('Could not get downloads directory.');

//     final safeFilename = filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
//     final savePath = p.join(dir.path, safeFilename);
    
//     final file = File(savePath);
//     await file.writeAsBytes(bytes);
//     await OpenFile.open(savePath);
//   };
// });

// lib/core/providers/app_providers.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:my_api_tester/core/models/execution_result.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../api/api_service.dart';
import '../database/database_service.dart';
import '../models/api_request.dart';

// --- Core Providers ---
final navigationIndexProvider = StateProvider<int>((ref) => 0);
final databaseProvider =
    Provider<DatabaseService>((ref) => DatabaseService.instance);
final requestsProvider =
    FutureProvider.autoDispose<List<ApiRequest>>((ref) async {
  final dbService = ref.watch(databaseProvider);
  return dbService.getRequests();
});
final dioProvider = Provider<Dio>((ref) => Dio());
final apiServiceProvider =
    Provider<ApiService>((ref) => ApiService(ref.watch(dioProvider)));

// --- State Notifier for the active request form ---
final activeRequestProvider =
    StateNotifierProvider.autoDispose<ActiveRequestNotifier, ApiRequest>((ref) {
  return ActiveRequestNotifier();
});

class ActiveRequestNotifier extends StateNotifier<ApiRequest> {
  ActiveRequestNotifier() : super(ApiRequest.newUnsaved());

  void loadRequest(ApiRequest request) {
    state = request;
  }

  void newRequest() {
    state = ApiRequest.newUnsaved();
  }

  void updateUrl(String url) => state = state.copyWith(url: url);
  void updateMethod(String method) => state = state.copyWith(method: method);
  void updateBody(String body) => state = state.copyWith(body: body);
  void updateBodyType(BodyType type) => state = state.copyWith(bodyType: type);

  void _updateMap({
    required Map<String, String> map,
    required int index,
    required String key,
    required String value,
    required Function(Map<String, String>) onUpdate,
  }) {
    final entries = map.entries.toList();
    if (index >= entries.length) return;
    final oldEntry = entries[index];
    final newMap = Map.of(map);
    newMap.remove(oldEntry.key);
    newMap[key] = value;
    onUpdate(newMap);
  }

  void addHeader() {
    state = state.copyWith(headers: {...state.headers, '': ''});
  }

  void removeHeader(int index) {
    final entries = state.headers.entries.toList();
    if (index >= entries.length) return;
    final newHeaders = Map.of(state.headers)..remove(entries[index].key);
    state = state.copyWith(headers: newHeaders);
  }

  void updateHeader(int index, {String? key, String? value}) {
    final entries = state.headers.entries.toList();
    if (index >= entries.length) return;
    final oldEntry = entries[index];
    _updateMap(
      map: state.headers,
      index: index,
      key: key ?? oldEntry.key,
      value: value ?? oldEntry.value,
      onUpdate: (newMap) => state = state.copyWith(headers: newMap),
    );
  }

  void addParam() {
    state = state.copyWith(params: {...state.params, '': ''});
  }

  void removeParam(int index) {
    final entries = state.params.entries.toList();
    if (index >= entries.length) return;
    final newParams = Map.of(state.params)..remove(entries[index].key);
    state = state.copyWith(params: newParams);
  }

  void updateParam(int index, {String? key, String? value}) {
    final entries = state.params.entries.toList();
    if (index >= entries.length) return;
    final oldEntry = entries[index];
    _updateMap(
      map: state.params,
      index: index,
      key: key ?? oldEntry.key,
      value: value ?? oldEntry.value,
      onUpdate: (newMap) => state = state.copyWith(params: newMap),
    );
  }

  void addFormDataFile(String key, PlatformFile file) {
    state = state.copyWith(formDataFiles: {...state.formDataFiles, key: file});
  }

  void removeFormDataFile(String key) {
    final newFiles = Map.of(state.formDataFiles)..remove(key);
    state = state.copyWith(formDataFiles: newFiles);
  }
}

// --- Response Handling Providers ---

final responseStateProvider =
    StateProvider.autoDispose<AsyncValue<ExecutionResult>?>((ref) {
  return null;
});

final sendRequestProvider =
    Provider.autoDispose<Future<void> Function()>((ref) {
  return () async {
    ref.read(responseStateProvider.notifier).state = const AsyncValue.loading();
    final apiService = ref.read(apiServiceProvider);
    final request = ref.read(activeRequestProvider);
    final result =
        await AsyncValue.guard(() => apiService.executeRequest(request));
    ref.read(responseStateProvider.notifier).state = result;
  };
});

final saveFileProvider =
    Provider.autoDispose<Future<void> Function(Uint8List, String)>((ref) {
  return (bytes, filename) async {
    final dir = await getDownloadsDirectory();
    if (dir == null) throw Exception('Could not get downloads directory.');
    final safeFilename = filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    final savePath = p.join(dir.path, safeFilename);
    final file = File(savePath);
    await file.writeAsBytes(bytes);
    // await OpenFile.open(savePath);
  };
});

// --- NEW PROVIDER TO SAVE BYTES TO A USER-CHOSEN LOCATION ---
final saveBytesAsFileProvider = Provider.autoDispose<
    // It takes the bytes and a suggested filename
    Future<void> Function(Uint8List, String)>((ref) {
  return (bytes, suggestedName) async {
    // This opens the native "Save As..." dialog
    String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: suggestedName,
    );

    // The user may have cancelled the dialog
    if (outputPath == null) {
      throw Exception('Save operation cancelled by user.');
    }

    final file = File(outputPath);
    await file.writeAsBytes(bytes);
  };
});