// // lib/features/shell/app_shell.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../core/providers/app_providers.dart';
// import '../sidebar/sidebar_view.dart';
// import '../views/history_view.dart';
// import '../views/settings_view.dart';
// import '../views/tester_view.dart';

// class AppShell extends ConsumerWidget {
//   const AppShell({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Watch the provider to get the currently selected navigation index
//     final selectedIndex = ref.watch(navigationIndexProvider);

//     return Scaffold(
//       body: Row(
//         children: [
//           // 1. The Navigation Rail (Nav Bar)
//           NavigationRail(
//             selectedIndex: selectedIndex,
//             onDestinationSelected: (index) {
//               // When an item is tapped, update the state provider
//               ref.read(navigationIndexProvider.notifier).state = index;
//             },
//             labelType: NavigationRailLabelType.all,
//             destinations: const [
//               NavigationRailDestination(
//                 icon: Icon(Icons.http_outlined),
//                 selectedIcon: Icon(Icons.http),
//                 label: Text('Tester'),
//               ),
//               NavigationRailDestination(
//                 icon: Icon(Icons.history_outlined),
//                 selectedIcon: Icon(Icons.history),
//                 label: Text('History'),
//               ),
//               NavigationRailDestination(
//                 icon: Icon(Icons.settings_outlined),
//                 selectedIcon: Icon(Icons.settings),
//                 label: Text('Settings'),
//               ),
//             ],
//           ),
//           const VerticalDivider(thickness: 1, width: 1),

//           // 2. The Sidebar
//           const SidebarView(),
//           const VerticalDivider(thickness: 1, width: 1),

//           // 3. The Main Content Area
//           Expanded(
//             // IndexedStack efficiently switches between views without rebuilding them
//             child: IndexedStack(
//               index: selectedIndex,
//               children: const [
//                 TesterView(),   // Index 0
//                 HistoryView(),  // Index 1
//                 SettingsView(), // Index 2
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/features/shell/app_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../views/history_view.dart';
import '../views/settings_view.dart';
import '../views/tester_view.dart';

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
                HistoryView(),  // Index 1
                SettingsView(), // Index 2
              ],
            ),
          ),
        ],
      ),
    );
  }
}