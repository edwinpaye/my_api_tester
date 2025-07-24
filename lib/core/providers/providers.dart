// lib/core/providers/providers.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_service.dart';
import '../models/api_request.dart';
import '../models/api_response.dart';

// 1. Provider for the Dio instance
final dioProvider = Provider<Dio>((ref) => Dio());

// 2. Provider for our ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.watch(dioProvider));
});

// 3. StateNotifier for the request being edited in the UI
final activeRequestProvider =
    StateNotifierProvider<ActiveRequestNotifier, ApiRequest>((ref) {
  return ActiveRequestNotifier();
});

class ActiveRequestNotifier extends StateNotifier<ApiRequest> {
  ActiveRequestNotifier() : super(ApiRequest.empty());

  void updateUrl(String url) => state = state.copyWith(url: url);
  void updateMethod(String method) => state = state.copyWith(method: method);
  void updateBody(String body) => state = state.copyWith(body: body);

  // Helper to update a map (for headers and params)
  void _updateMap(
      {required Map<String, String> map,
      required int index,
      required String key,
      required String value,
      required Function(Map<String, String>) onUpdate}) {
    // To update a key, we need to remove the old one and add the new one
    final entries = map.entries.toList();
    final oldEntry = entries[index];
    
    // Explicitly create a Map<String, String> to ensure type safety.
    final newMap = Map<String, String>.from(map); // <<< FIX HERE

    newMap.remove(oldEntry.key);
    newMap[key] = value;
    onUpdate(newMap);
  }

  void addHeader() {
    final newHeaders = Map.of(state.headers)..[''] = '';
    state = state.copyWith(headers: newHeaders);
  }

  void removeHeader(int index) {
    final entries = state.headers.entries.toList();
    final newHeaders = Map.of(state.headers)..remove(entries[index].key);
    state = state.copyWith(headers: newHeaders);
  }

  void updateHeader(int index, {String? key, String? value}) {
    final entries = state.headers.entries.toList();
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
    final newParams = Map.of(state.params)..[''] = '';
    state = state.copyWith(params: newParams);
  }

  void removeParam(int index) {
    final entries = state.params.entries.toList();
    final newParams = Map.of(state.params)..remove(entries[index].key);
    state = state.copyWith(params: newParams);
  }

  void updateParam(int index, {String? key, String? value}) {
    final entries = state.params.entries.toList();
    final oldEntry = entries[index];
    _updateMap(
      map: state.params,
      index: index,
      key: key ?? oldEntry.key,
      value: value ?? oldEntry.value,
      onUpdate: (newMap) => state = state.copyWith(params: newMap),
    );
  }
}

// 4. Provider to hold the state of the last API response.
final responseStateProvider = StateProvider<AsyncValue<ApiResponse>>((ref) {
  return const AsyncValue.data(ApiResponse(
      statusCode: 0,
      body: "Ready to send a request...",
      headers: {},
      timeTaken: Duration.zero));
});

// 5. Provider to trigger the API call.
final sendRequestProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    ref.read(responseStateProvider.notifier).state = const AsyncValue.loading();
    final apiService = ref.read(apiServiceProvider);
    final request = ref.read(activeRequestProvider);

    try {
      final response = await apiService.execute(request);
      ref.read(responseStateProvider.notifier).state = AsyncValue.data(response);
    } catch (e, s) {
      ref.read(responseStateProvider.notifier).state = AsyncValue.error(e, s);
    }
  };
});