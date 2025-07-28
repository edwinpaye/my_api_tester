// lib/features/utilities/utilities_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views/base64_decoder_view.dart';
import 'views/ssh_explorer_view.dart';

// A provider to manage which utility is currently selected
final selectedUtilityIndexProvider = StateProvider<int>((ref) => 0);

class UtilitiesShell extends ConsumerWidget {
  const UtilitiesShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedUtilityIndexProvider);
    final notifier = ref.read(selectedUtilityIndexProvider.notifier);

    const utilityViews = [
      Base64DecoderView(),
      SshExplorerView(),
    ];

    return Row(
      children: [
        // Utilities Sidebar
        Container(
          width: 200,
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.transform),
                title: const Text('Base64 Decoder'),
                selected: selectedIndex == 0,
                onTap: () => notifier.state = 0,
              ),
              ListTile(
                leading: const Icon(Icons.folder_open),
                title: const Text('SSH Explorer'),
                selected: selectedIndex == 1,
                onTap: () => notifier.state = 1,
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),

        // Main content area for the selected utility
        Expanded(
          child: IndexedStack(
            index: selectedIndex,
            children: utilityViews,
          ),
        )
      ],
    );
  }
}