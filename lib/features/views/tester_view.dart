// // lib/features/views/tester_view.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_syntax_view/flutter_syntax_view.dart';
// import '../../core/models/api_request.dart';
// import '../../core/providers/app_providers.dart';
// import '../sidebar/sidebar_view.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:path/path.dart' as p;
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import '../../core/models/api_response.dart';
// import '../../core/models/execution_result.dart';

// class TesterView extends ConsumerWidget {
//   const TesterView({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return const Scaffold(
//       body: Row(
//         children: [
//           SidebarView(),
//           VerticalDivider(thickness: 1, width: 1),
//           Expanded(
//             // Use a Column to stack the request and response panels
//             child: Column(
//               children: [
//                 Expanded(
//                   flex: 2, // Give more space to the request editor initially
//                   child: RequestEditorPanel(),
//                 ),
//                 Divider(height: 1, thickness: 1),
//                 Expanded(
//                   flex: 3, // Give more space to the response
//                   child: ResponsePanel(),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // --- The Main Request Form Widget ---
// class RequestEditorPanel extends ConsumerWidget {
//   const RequestEditorPanel({super.key});

//   Future<void> _saveRequest(WidgetRef ref, BuildContext context) async {
//     final requestToSave = ref.read(activeRequestProvider);
//     if (requestToSave.url.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Cannot save a request with an empty URL.')),
//       );
//       return;
//     }
//     await ref.read(databaseProvider).insertRequest(requestToSave);
//     ref.invalidate(requestsProvider);
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Request saved!')),
//     );
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final request = ref.watch(activeRequestProvider);
//     final notifier = ref.read(activeRequestProvider.notifier);

//     return DefaultTabController(
//       length: 3,
//       key: ValueKey(request.id ?? 'new'),
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 DropdownButton<String>(
//                   value: request.method,
//                   items: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']
//                       .map((method) => DropdownMenuItem(value: method, child: Text(method)))
//                       .toList(),
//                   onChanged: (value) => notifier.updateMethod(value!),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: TextFormField(
//                     initialValue: request.url,
//                     decoration: const InputDecoration(hintText: 'Enter request URL', border: OutlineInputBorder()),
//                     onChanged: notifier.updateUrl,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   icon: const Icon(Icons.save),
//                   tooltip: 'Save Request',
//                   onPressed: () => _saveRequest(ref, context),
//                 ),
//                 const SizedBox(width: 8),
//                 // The "Send" button
//                 // ElevatedButton.icon(
//                 //   icon: const Icon(Icons.send),
//                 //   label: const Text('Send'),
//                 //   onPressed: ref.read(sendRequestProvider),
//                 //   style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
//                 // ),
//                 ElevatedButton.icon(
//                     icon: const Icon(Icons.send),
//                     label: const Text('Send'),
//                     onPressed: ref.read(sendRequestProvider),
//                     style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
//                 ),
//               ],
//             ),
//           ),
//           const TabBar(tabs: [Tab(text: 'Params'), Tab(text: 'Headers'), Tab(text: 'Body')]),
//           Expanded(
//             child: TabBarView(
//               children: [
//                 _KeyValueEditor(items: request.params, onAdd: notifier.addParam, onRemove: notifier.removeParam, onUpdateKey: (i, k) => notifier.updateParam(i, key: k), onUpdateValue: (i, v) => notifier.updateParam(i, value: v)),
//                 _KeyValueEditor(items: request.headers, onAdd: notifier.addHeader, onRemove: notifier.removeHeader, onUpdateKey: (i, k) => notifier.updateHeader(i, key: k), onUpdateValue: (i, v) => notifier.updateHeader(i, value: v)),
//                 // _BodyEditor(body: request.body, onChanged: notifier.updateBody),
//                 _BodyTabView(), 
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }


// // --- NEW, SMART ResponsePanel ---
// class ResponsePanel extends ConsumerWidget {
//   const ResponsePanel({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final responseAsync = ref.watch(responseStateProvider);

//     if (responseAsync == null) {
//       return const Center(child: Text('Press "Send" to make a request.'));
//     }

//     return responseAsync.when(
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (err, stack) => Center(child: Text('Error: $err')),
//       data: (result) {
//         // --- HERE IS THE SWITCH ON THE RESULT TYPE ---
//         return switch (result) {
//           // Case 1: The result was a file
//           FileResult(:final bytes, :final filename) =>
//             _FileResponseView(bytes: bytes, filename: filename),
          
//           // Case 2: The result was text
//           TextResult(:final response) =>
//             _TextResponseView(response: response),
//         };
//       },
//     );
//   }
// }

// // --- NEW WIDGET to display when a file is received ---
// class _FileResponseView extends ConsumerWidget {
//   const _FileResponseView({required this.bytes, required this.filename});
//   final Uint8List bytes;
//   final String filename;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Center(
//       child: Column(
//         mainAxisAlignment.center,
//         children: [
//           const Icon(Icons.description, size: 60, color: Colors.grey),
//           const SizedBox(height: 16),
//           Text(
//             'File Response Received',
//             style: Theme.of(context).textTheme.headlineSmall,
//           ),
//           const SizedBox(height: 8),
//           Text(filename),
//           Text('${(bytes.lengthInBytes / 1024).toStringAsFixed(2)} KB'),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.save_alt),
//             label: const Text('Save File'),
//             onPressed: () async {
//               try {
//                 await ref.read(saveFileProvider)(bytes, filename);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('File saved to Downloads!')),
//                 );
//               } catch (e) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Failed to save file: $e')),
//                 );
//               }
//             },
//           )
//         ],
//       ),
//     );
//   }
// }

// // --- This is the OLD ResponsePanel, refactored into its own widget ---
// class _TextResponseView extends StatelessWidget {
//   const _TextResponseView({required this.response});
//   final ApiResponse response;

//   @override
//   Widget build(BuildContext context) {
//     // ... The entire implementation of the old ResponsePanel's
//     // DefaultTabController with the status bar, body/header tabs,
//     // and SyntaxView goes here.
//     // Make sure to use the `response` object passed in.
//     final responseAsync = ref.watch(responseStateProvider);
//     final theme = Theme.of(context);
//     final isDarkTheme = theme.brightness == Brightness.dark;

//     // Show a welcome message if no request has been sent yet
//     if (responseAsync == null) {
//       return const Center(child: Text('Press "Send" to make a request.'));
//     }

//     return responseAsync.when(
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (err, stack) => Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: $err', style: const TextStyle(color: Colors.red)))),
//       data: (response) {
//         Color getStatusColor(int statusCode) {
//           if (statusCode >= 200 && statusCode < 300) return Colors.green;
//           if (statusCode >= 400) return Colors.red;
//           if (statusCode >= 300) return Colors.orange;
//           return Colors.grey;
//         }

//         return DefaultTabController(
//           length: 2,
//           child: Column(
//             children: [
//               Container(
//                 color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                 child: Row(
//                     children: [
//                         SelectableText('Status: ${response.statusCode}', style: TextStyle(color: getStatusColor(response.statusCode), fontWeight: FontWeight.bold)),
//                         const Spacer(),
//                         SelectableText('Time: ${response.timeTaken.inMilliseconds} ms'),
//                         const Spacer(),
//                         // NEW Download Button
//                         // IconButton(
//                         //     icon: const Icon(Icons.download),
//                         //     tooltip: 'Download Response Body',
//                         //     onPressed: response.body.isNotEmpty ? () {
//                         //         // Here you'd call a download provider. For now, we use the active request URL as a dummy.
//                         //         final urlToDownload = ref.read(activeRequestProvider).url;
//                         //         ref.read(downloadProvider)(urlToDownload).catchError((e) {
//                         //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e')));
//                         //         });
//                         //     } : null, // Disable if body is empty
//                         // ),
//                         IconButton(
//                             icon: const Icon(Icons.download),
//                             tooltip: 'Save Response Body to File',
//                             onPressed: response.body.isNotEmpty
//                                 ? () async {
//                                     try {
//                                         // Call the updated provider with the body AND the headers map
//                                         await ref.read(saveResponseBodyProvider)(response.body, response.headers);
//                                         ScaffoldMessenger.of(context).showSnackBar(
//                                         const SnackBar(content: Text('Response saved to Downloads!')),
//                                         );
//                                     } catch (e) {
//                                         ScaffoldMessenger.of(context).showSnackBar(
//                                         SnackBar(content: Text('Failed to save file: $e')),
//                                         );
//                                     }
//                                     }
//                                 : null,
//                         ),
//                     ],
//                 ),
//               ),
//               const TabBar(tabs: [Tab(text: 'Body'), Tab(text: 'Headers')]),
//               Expanded(
//                 child: TabBarView(
//                   children: [
//                     // Body View with JSON formatting
//                     SyntaxView(
//                       code: response.body,
//                       syntax: Syntax.JAVASCRIPT, // JSON is a subset of JS
//                       syntaxTheme: isDarkTheme ? SyntaxTheme.vscodeDark() : SyntaxTheme.vscodeLight(),
//                       expanded: true,
//                     ),
//                     // Headers View
//                     ListView(
//                       children: response.headers.entries.map((entry) {
//                         final values = entry.value as List<String>;
//                         return ListTile(title: SelectableText(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: SelectableText(values.join('\n')));
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// // // --- The New Response Panel Widget ---
// // class ResponsePanel extends ConsumerWidget {
// //   const ResponsePanel({super.key});

// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     final responseAsync = ref.watch(responseStateProvider);
// //     final theme = Theme.of(context);
// //     final isDarkTheme = theme.brightness == Brightness.dark;

// //     // Show a welcome message if no request has been sent yet
// //     if (responseAsync == null) {
// //       return const Center(child: Text('Press "Send" to make a request.'));
// //     }

// //     return responseAsync.when(
// //       loading: () => const Center(child: CircularProgressIndicator()),
// //       error: (err, stack) => Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: $err', style: const TextStyle(color: Colors.red)))),
// //       data: (response) {
// //         Color getStatusColor(int statusCode) {
// //           if (statusCode >= 200 && statusCode < 300) return Colors.green;
// //           if (statusCode >= 400) return Colors.red;
// //           if (statusCode >= 300) return Colors.orange;
// //           return Colors.grey;
// //         }

// //         return DefaultTabController(
// //           length: 2,
// //           child: Column(
// //             children: [
// //               Container(
// //                 color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
// //                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
// //                 child: Row(
// //                     children: [
// //                         SelectableText('Status: ${response.statusCode}', style: TextStyle(color: getStatusColor(response.statusCode), fontWeight: FontWeight.bold)),
// //                         const Spacer(),
// //                         SelectableText('Time: ${response.timeTaken.inMilliseconds} ms'),
// //                         const Spacer(),
// //                         // NEW Download Button
// //                         // IconButton(
// //                         //     icon: const Icon(Icons.download),
// //                         //     tooltip: 'Download Response Body',
// //                         //     onPressed: response.body.isNotEmpty ? () {
// //                         //         // Here you'd call a download provider. For now, we use the active request URL as a dummy.
// //                         //         final urlToDownload = ref.read(activeRequestProvider).url;
// //                         //         ref.read(downloadProvider)(urlToDownload).catchError((e) {
// //                         //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e')));
// //                         //         });
// //                         //     } : null, // Disable if body is empty
// //                         // ),
// //                         IconButton(
// //                             icon: const Icon(Icons.download),
// //                             tooltip: 'Save Response Body to File',
// //                             onPressed: response.body.isNotEmpty
// //                                 ? () async {
// //                                     try {
// //                                         // Call the updated provider with the body AND the headers map
// //                                         await ref.read(saveResponseBodyProvider)(response.body, response.headers);
// //                                         ScaffoldMessenger.of(context).showSnackBar(
// //                                         const SnackBar(content: Text('Response saved to Downloads!')),
// //                                         );
// //                                     } catch (e) {
// //                                         ScaffoldMessenger.of(context).showSnackBar(
// //                                         SnackBar(content: Text('Failed to save file: $e')),
// //                                         );
// //                                     }
// //                                     }
// //                                 : null,
// //                         ),
// //                     ],
// //                 ),
// //               ),
// //               const TabBar(tabs: [Tab(text: 'Body'), Tab(text: 'Headers')]),
// //               Expanded(
// //                 child: TabBarView(
// //                   children: [
// //                     // Body View with JSON formatting
// //                     SyntaxView(
// //                       code: response.body,
// //                       syntax: Syntax.JAVASCRIPT, // JSON is a subset of JS
// //                       syntaxTheme: isDarkTheme ? SyntaxTheme.vscodeDark() : SyntaxTheme.vscodeLight(),
// //                       expanded: true,
// //                     ),
// //                     // Headers View
// //                     ListView(
// //                       children: response.headers.entries.map((entry) {
// //                         final values = entry.value as List<String>;
// //                         return ListTile(title: SelectableText(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: SelectableText(values.join('\n')));
// //                       }).toList(),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }

// // --- NEW WIDGET for the Body Tab ---
// class _BodyTabView extends ConsumerWidget {
//   const _BodyTabView();

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final bodyType = ref.watch(activeRequestProvider.select((req) => req.bodyType));
    
//     return Column(
//       children: [
//         // Radio buttons to select body type
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Radio<BodyType>(value: BodyType.none, groupValue: bodyType, onChanged: (v) => ref.read(activeRequestProvider.notifier).updateBodyType(v!)), const Text('None'),
//             Radio<BodyType>(value: BodyType.json, groupValue: bodyType, onChanged: (v) => ref.read(activeRequestProvider.notifier).updateBodyType(v!)), const Text('JSON'),
//             Radio<BodyType>(value: BodyType.formData, groupValue: bodyType, onChanged: (v) => ref.read(activeRequestProvider.notifier).updateBodyType(v!)), const Text('Form-Data'),
//           ],
//         ),
//         const Divider(),
//         Expanded(
//           child: switch(bodyType) {
//             BodyType.none => const Center(child: Text('This request has no body.')),
//             BodyType.json => _BodyEditor(body: ref.watch(activeRequestProvider).body, onChanged: ref.read(activeRequestProvider.notifier).updateBody),
//             BodyType.formData => const _FormDataEditor(),
//           }
//         ),
//       ],
//     );
//   }
// }

// // --- NEW WIDGET for editing Form-Data ---
// class _FormDataEditor extends ConsumerWidget {
//   const _FormDataEditor();

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final request = ref.watch(activeRequestProvider);
//     final notifier = ref.read(activeRequestProvider.notifier);

//     return Column(
//       children: [
//         // Display selected files
//         ...request.formDataFiles.entries.map((entry) => ListTile(
//           leading: const Icon(Icons.attach_file),
//           title: Text(entry.value.name),
//           subtitle: Text('${(entry.value.size / 1024).toStringAsFixed(2)} KB'),
//           trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => notifier.removeFormDataFile(entry.key)),
//         )),
//         // In a real app, you'd have a _KeyValueEditor for text fields here
//         Center(
//           child: ElevatedButton.icon(
//             icon: const Icon(Icons.upload_file),
//             label: const Text('Add File'),
//             onPressed: () async {
//               final result = await FilePicker.platform.pickFiles();
//               if (result != null && result.files.single.path != null) {
//                 // For simplicity, we use the filename as the key
//                 notifier.addFormDataFile(result.files.single.name, result.files.single);
//               }
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

// // // lib/features/views/tester_view.dart
// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import '../../core/models/api_request.dart';
// // import '../../core/providers/app_providers.dart';
// // import '../sidebar/sidebar_view.dart';

// // class TesterView extends ConsumerWidget {
// //   const TesterView({super.key});

// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     return const Scaffold(
// //       body: Row(
// //         children: [
// //           SidebarView(),
// //           VerticalDivider(thickness: 1, width: 1),
// //           Expanded(
// //             child: RequestEditorPanel(),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // --- The Main Request Form Widget ---
// // class RequestEditorPanel extends ConsumerWidget {
// //   const RequestEditorPanel({super.key});

// //   Future<void> _saveRequest(WidgetRef ref, BuildContext context) async {
// //     final requestToSave = ref.read(activeRequestProvider);
// //     await ref.read(databaseProvider).insertRequest(requestToSave);
// //     ref.invalidate(requestsProvider);
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(content: Text('Request saved!')),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     // Watch the active request provider to rebuild the form when state changes
// //     final request = ref.watch(activeRequestProvider);
// //     final notifier = ref.read(activeRequestProvider.notifier);

// //     return DefaultTabController(
// //       length: 3,
// //       // Use a key to force the entire widget to rebuild when the request ID changes
// //       // This is crucial for making the form fully reactive to sidebar clicks.
// //       key: ValueKey(request.id ?? 'new'),
// //       child: Column(
// //         children: [
// //           // Top bar with URL and action buttons
// //           Padding(
// //             padding: const EdgeInsets.all(8.0),
// //             child: Row(
// //               children: [
// //                 DropdownButton<String>(
// //                   value: request.method,
// //                   items: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']
// //                       .map((method) =>
// //                           DropdownMenuItem(value: method, child: Text(method)))
// //                       .toList(),
// //                   onChanged: (value) {
// //                     if (value != null) notifier.updateMethod(value);
// //                   },
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Expanded(
// //                   child: TextFormField(
// //                     initialValue: request.url,
// //                     decoration: const InputDecoration(
// //                         hintText: 'Enter request URL',
// //                         border: OutlineInputBorder()),
// //                     onChanged: notifier.updateUrl,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 ElevatedButton.icon(
// //                   icon: const Icon(Icons.save),
// //                   label: const Text('Save'),
// //                   onPressed: () => _saveRequest(ref, context),
// //                 )
// //               ],
// //             ),
// //           ),
// //           const TabBar(
// //             tabs: [
// //               Tab(text: 'Params'),
// //               Tab(text: 'Headers'),
// //               Tab(text: 'Body'),
// //             ],
// //           ),
// //           // Tab contents
// //           Expanded(
// //             child: TabBarView(
// //               children: [
// //                 _KeyValueEditor(
// //                     items: request.params,
// //                     onAdd: notifier.addParam,
// //                     onRemove: notifier.removeParam,
// //                     onUpdateKey: (i, k) => notifier.updateParam(i, key: k),
// //                     onUpdateValue: (i, v) => notifier.updateParam(i, value: v)),
// //                 _KeyValueEditor(
// //                     items: request.headers,
// //                     onAdd: notifier.addHeader,
// //                     onRemove: notifier.removeHeader,
// //                     onUpdateKey: (i, k) => notifier.updateHeader(i, key: k),
// //                     onUpdateValue: (i, v) => notifier.updateHeader(i, value: v)),
// //                 _BodyEditor(body: request.body, onChanged: notifier.updateBody),
// //               ],
// //             ),
// //           )
// //         ],
// //       ),
// //     );
// //   }
// // }

// // Reusable widget for editing key-value pairs
// class _KeyValueEditor extends StatelessWidget {
//   const _KeyValueEditor(
//       {required this.items,
//       required this.onAdd,
//       required this.onRemove,
//       required this.onUpdateKey,
//       required this.onUpdateValue});

//   final Map<String, String> items;
//   final VoidCallback onAdd;
//   final ValueChanged<int> onRemove;
//   final void Function(int, String) onUpdateKey;
//   final void Function(int, String) onUpdateValue;

//   @override
//   Widget build(BuildContext context) {
//     final entries = items.entries.toList();
//     return Column(
//       children: [
//         Expanded(
//           child: ListView.builder(
//             itemCount: entries.length,
//             itemBuilder: (context, index) {
//               final entry = entries[index];
//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//                 child: Row(children: [
//                   Expanded(
//                       child: TextFormField(
//                           initialValue: entry.key,
//                           decoration: const InputDecoration(
//                               labelText: 'Key', border: OutlineInputBorder()),
//                           onChanged: (key) => onUpdateKey(index, key))),
//                   const SizedBox(width: 8),
//                   Expanded(
//                       child: TextFormField(
//                           initialValue: entry.value,
//                           decoration: const InputDecoration(
//                               labelText: 'Value', border: OutlineInputBorder()),
//                           onChanged: (value) => onUpdateValue(index, value))),
//                   IconButton(
//                       icon: const Icon(Icons.remove_circle_outline),
//                       onPressed: () => onRemove(index)),
//                 ]),
//               );
//             },
//           ),
//         ),
//         Align(
//             alignment: Alignment.centerRight,
//             child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: TextButton.icon(
//                     icon: const Icon(Icons.add),
//                     label: const Text('Add Row'),
//                     onPressed: onAdd)))
//       ],
//     );
//   }
// }

// // Widget for editing the request body
// class _BodyEditor extends StatelessWidget {
//   const _BodyEditor({required this.body, required this.onChanged});
//   final String body;
//   final ValueChanged<String> onChanged;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: TextFormField(
//         initialValue: body,
//         onChanged: onChanged,
//         decoration: const InputDecoration(
//             border: OutlineInputBorder(),
//             hintText: 'Enter request body (e.g., JSON)'),
//         maxLines: null,
//         expands: true,
//         textAlignVertical: TextAlignVertical.top,
//       ),
//     );
//   }
// }


// lib/features/views/tester_view.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:file_picker/file_picker.dart'; // <-- THE FIX
import '../../core/models/api_request.dart';
import '../../core/models/api_response.dart';
import '../../core/models/execution_result.dart';
import '../../core/providers/app_providers.dart';
import '../sidebar/sidebar_view.dart';


class TesterView extends ConsumerWidget {
  const TesterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: Row(
        children: [
          SidebarView(),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: RequestEditorPanel(),
                ),
                Divider(height: 1, thickness: 1),
                Expanded(
                  flex: 3,
                  child: ResponsePanel(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RequestEditorPanel extends ConsumerWidget {
  const RequestEditorPanel({super.key});

  Future<void> _saveRequest(WidgetRef ref, BuildContext context) async {
    final requestToSave = ref.read(activeRequestProvider);
    if (requestToSave.url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot save a request with an empty URL.')),
      );
      return;
    }
    await ref.read(databaseProvider).insertRequest(requestToSave);
    ref.invalidate(requestsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request saved!')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ref.watch(activeRequestProvider);
    final notifier = ref.read(activeRequestProvider.notifier);

    return DefaultTabController(
      length: 3,
      key: ValueKey(request.id ?? 'new'),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: request.method,
                  items: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']
                      .map((method) => DropdownMenuItem(value: method, child: Text(method)))
                      .toList(),
                  onChanged: (value) => notifier.updateMethod(value!),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: request.url,
                    decoration: const InputDecoration(hintText: 'Enter request URL', border: OutlineInputBorder()),
                    onChanged: notifier.updateUrl,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.save),
                  tooltip: 'Save Request',
                  onPressed: () => _saveRequest(ref, context),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Send'),
                  onPressed: ref.read(sendRequestProvider),
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
                ),
              ],
            ),
          ),
          const TabBar(tabs: [Tab(text: 'Params'), Tab(text: 'Headers'), Tab(text: 'Body')]),
          Expanded(
            child: TabBarView(
              children: [
                _KeyValueEditor(items: request.params, onAdd: notifier.addParam, onRemove: notifier.removeParam, onUpdateKey: (i, k) => notifier.updateParam(i, key: k), onUpdateValue: (i, v) => notifier.updateParam(i, value: v)),
                _KeyValueEditor(items: request.headers, onAdd: notifier.addHeader, onRemove: notifier.removeHeader, onUpdateKey: (i, k) => notifier.updateHeader(i, key: k), onUpdateValue: (i, v) => notifier.updateHeader(i, value: v)),
                const _BodyTabView(),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ResponsePanel extends ConsumerWidget {
  const ResponsePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responseAsync = ref.watch(responseStateProvider);

    if (responseAsync == null) {
      return const Center(child: Text('Press "Send" to make a request.'));
    }

    return responseAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (result) {
        return switch (result) {
          FileResult(:final bytes, :final filename) =>
            _FileResponseView(bytes: bytes, filename: filename),
          TextResult(:final response) =>
            _TextResponseView(response: response),
        };
      },
    );
  }
}

class _FileResponseView extends ConsumerWidget {
  const _FileResponseView({required this.bytes, required this.filename});
  final Uint8List bytes;
  final String filename;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.description, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text('File Response Received', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(filename),
          Text('${(bytes.lengthInBytes / 1024).toStringAsFixed(2)} KB'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.save_alt),
            label: const Text('Save File'),
            onPressed: () async {
              try {
                await ref.read(saveFileProvider)(bytes, filename);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File saved to Downloads!')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save file: $e')));
              }
            },
          )
        ],
      ),
    );
  }
}

class _TextResponseView extends StatelessWidget {
  const _TextResponseView({required this.response});
  final ApiResponse response;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    Color getStatusColor(int statusCode) {
      if (statusCode >= 200 && statusCode < 300) return Colors.green;
      if (statusCode >= 400) return Colors.red;
      if (statusCode >= 300) return Colors.orange;
      return Colors.grey;
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                SelectableText('Status: ${response.statusCode}', style: TextStyle(color: getStatusColor(response.statusCode), fontWeight: FontWeight.bold)),
                const Spacer(),
                SelectableText('Time: ${response.timeTaken.inMilliseconds} ms'),
              ],
            ),
          ),
          const TabBar(tabs: [Tab(text: 'Body'), Tab(text: 'Headers')]),
          Expanded(
            child: TabBarView(
              children: [
                SyntaxView(
                  code: response.body,
                  syntax: Syntax.JAVASCRIPT,
                  syntaxTheme: isDarkTheme ? SyntaxTheme.vscodeDark() : SyntaxTheme.vscodeLight(),
                  expanded: true,
                ),
                ListView(
                  children: response.headers.entries.map((entry) {
                    final values = entry.value as List<String>;
                    return ListTile(title: SelectableText(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: SelectableText(values.join('\n')));
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyTabView extends ConsumerWidget {
  const _BodyTabView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodyType = ref.watch(activeRequestProvider.select((req) => req.bodyType));
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio<BodyType>(value: BodyType.none, groupValue: bodyType, onChanged: (v) => ref.read(activeRequestProvider.notifier).updateBodyType(v!)), const Text('None'),
            Radio<BodyType>(value: BodyType.json, groupValue: bodyType, onChanged: (v) => ref.read(activeRequestProvider.notifier).updateBodyType(v!)), const Text('JSON'),
            Radio<BodyType>(value: BodyType.formData, groupValue: bodyType, onChanged: (v) => ref.read(activeRequestProvider.notifier).updateBodyType(v!)), const Text('Form-Data'),
          ],
        ),
        const Divider(),
        Expanded(
          child: switch(bodyType) {
            BodyType.none => const Center(child: Text('This request has no body.')),
            BodyType.json => _BodyEditor(body: ref.watch(activeRequestProvider).body, onChanged: ref.read(activeRequestProvider.notifier).updateBody),
            BodyType.formData => const _FormDataEditor(),
          }
        ),
      ],
    );
  }
}

class _FormDataEditor extends ConsumerWidget {
  const _FormDataEditor();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ref.watch(activeRequestProvider);
    final notifier = ref.read(activeRequestProvider.notifier);

    return Column(
      children: [
        ...request.formDataFiles.entries.map((entry) => ListTile(
          leading: const Icon(Icons.attach_file),
          title: Text(entry.value.name),
          subtitle: Text('${(entry.value.size / 1024).toStringAsFixed(2)} KB'),
          trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => notifier.removeFormDataFile(entry.key)),
        )),
        Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text('Add File'),
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles();
              if (result != null && result.files.single.path != null) {
                notifier.addFormDataFile(result.files.single.name, result.files.single);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _KeyValueEditor extends StatelessWidget {
  const _KeyValueEditor(
      {required this.items,
      required this.onAdd,
      required this.onRemove,
      required this.onUpdateKey,
      required this.onUpdateValue});

  final Map<String, String> items;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final void Function(int, String) onUpdateKey;
  final void Function(int, String) onUpdateValue;

  @override
  Widget build(BuildContext context) {
    final entries = items.entries.toList();
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(children: [
                  Expanded(
                      child: TextFormField(
                          initialValue: entry.key,
                          decoration: const InputDecoration(
                              labelText: 'Key', border: OutlineInputBorder()),
                          onChanged: (key) => onUpdateKey(index, key))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: TextFormField(
                          initialValue: entry.value,
                          decoration: const InputDecoration(
                              labelText: 'Value', border: OutlineInputBorder()),
                          onChanged: (value) => onUpdateValue(index, value))),
                  IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => onRemove(index)),
                ]),
              );
            },
          ),
        ),
        Align(
            alignment: Alignment.centerRight,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Row'),
                    onPressed: onAdd)))
      ],
    );
  }
}

class _BodyEditor extends StatelessWidget {
  const _BodyEditor({required this.body, required this.onChanged});
  final String body;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        initialValue: body,
        onChanged: onChanged,
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter request body (e.g., JSON)'),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
      ),
    );
  }
}