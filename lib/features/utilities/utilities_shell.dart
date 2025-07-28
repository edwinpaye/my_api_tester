// lib/features/utilities/utilities_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views/base64_decoder_view.dart';

// A provider to manage which utility is currently selected
final selectedUtilityIndexProvider = StateProvider<int>((ref) => 0);

class UtilitiesShell extends ConsumerWidget {
  const UtilitiesShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedUtilityIndexProvider);
    final notifier = ref.read(selectedUtilityIndexProvider.notifier);

    // List of available utility widgets
    const utilityViews = [
      Base64DecoderView(),
      // Add more utility views here in the future
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
              // Add more ListTiles for future utilities here
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