// lib/features/shell/app_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../views/history_view.dart';
import '../views/settings_view.dart';
import '../views/tester_view.dart';
import '../utilities/utilities_shell.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      body: Row(
        children: [
          // 1. Navigation Rail
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              ref.read(navigationIndexProvider.notifier).state = index;
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                  icon: Icon(Icons.http_outlined),
                  selectedIcon: Icon(Icons.http),
                  label: Text('Tester')),
              NavigationRailDestination(
                  icon: Icon(Icons.construction_outlined),
                  selectedIcon: Icon(Icons.construction),
                  label: Text('Utilities')),
              NavigationRailDestination(
                  icon: Icon(Icons.history_outlined),
                  selectedIcon: Icon(Icons.history),
                  label: Text('History')),
              NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),

          // 2. Main Content Area (No Sidebar Here Anymore)
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: const [
                TesterView(),   // Index 0
                UtilitiesShell(), // Index 1
                HistoryView(),  // Index 2
                SettingsView(), // Index 3
              ],
            ),
          ),
        ],
      ),
    );
  }
}
