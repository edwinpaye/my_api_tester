// lib/features/request_panel/request_panel_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers.dart';

class RequestPanelView extends ConsumerWidget {
  const RequestPanelView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ref.watch(activeRequestProvider);
    final notifier = ref.read(activeRequestProvider.notifier);
    final urlController = TextEditingController(text: request.url);

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Top bar with URL and Send button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: request.method,
                  items: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']
                      .map((method) =>
                          DropdownMenuItem(value: method, child: Text(method)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) notifier.updateMethod(value);
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: urlController..text = request.url,
                    decoration: const InputDecoration(
                      hintText: 'Enter request URL',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onChanged: notifier.updateUrl,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: ref.read(sendRequestProvider),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16)),
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
          const TabBar(
            tabs: [
              Tab(text: 'Params'),
              Tab(text: 'Headers'),
              Tab(text: 'Body'),
            ],
          ),
          // Tab contents
          Expanded(
            child: TabBarView(
              children: [
                _KeyValueEditor(
                  items: request.params,
                  onAdd: notifier.addParam,
                  onRemove: notifier.removeParam,
                  onUpdateKey: (index, key) => notifier.updateParam(index, key: key),
                  onUpdateValue: (index, value) => notifier.updateParam(index, value: value),
                ),
                _KeyValueEditor(
                  items: request.headers,
                  onAdd: notifier.addHeader,
                  onRemove: notifier.removeHeader,
                  onUpdateKey: (index, key) => notifier.updateHeader(index, key: key),
                  onUpdateValue: (index, value) => notifier.updateHeader(index, value: value),
                ),
                _BodyEditor(
                  body: request.body,
                  onChanged: notifier.updateBody,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Reusable widget for editing key-value pairs
class _KeyValueEditor extends StatelessWidget {
  const _KeyValueEditor({
    required this.items,
    required this.onAdd,
    required this.onRemove,
    required this.onUpdateKey,
    required this.onUpdateValue,
  });

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
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: entry.key,
                        decoration: const InputDecoration(labelText: 'Key', border: OutlineInputBorder()),
                        onChanged: (key) => onUpdateKey(index, key),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: entry.value,
                        decoration: const InputDecoration(labelText: 'Value', border: OutlineInputBorder()),
                        onChanged: (value) => onUpdateValue(index, value),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => onRemove(index),
                    ),
                  ],
                ),
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
              label: const Text('Add'),
              onPressed: onAdd,
            ),
          ),
        ),
      ],
    );
  }
}

// Widget for editing the request body
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
          hintText: 'Enter request body (e.g., JSON)',
        ),
        maxLines: null, // Allows for unlimited lines
        expands: true, // Expands to fill available space
        textAlignVertical: TextAlignVertical.top,
      ),
    );
  }
}