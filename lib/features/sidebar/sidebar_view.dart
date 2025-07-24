// lib/features/sidebar/sidebar_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';

class SidebarView extends ConsumerWidget {
  const SidebarView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRequests = ref.watch(requestsProvider);

    return Container(
      width: 250,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Saved Requests',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          const Divider(height: 1),
          Expanded(
            child: asyncRequests.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (requests) {
                if (requests.isEmpty) {
                  return const Center(child: Text('No saved requests.'));
                }
                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return ListTile(
                      title: Text(request.url, overflow: TextOverflow.ellipsis),
                      leading: Text(request.method, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                      dense: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () async {
                          await ref.read(databaseProvider).deleteRequest(request.id!);
                          ref.invalidate(requestsProvider);
                        },
                      ),
                      // THIS IS THE NEW FUNCTIONALITY
                      onTap: () {
                        // Read the notifier and call the method to load the request
                        ref.read(activeRequestProvider.notifier).loadRequest(request);
                      },
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          // Add a "New Request" button at the bottom
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('New Request'),
            onTap: () {
              ref.read(activeRequestProvider.notifier).newRequest();
            },
          )
        ],
      ),
    );
  }
}