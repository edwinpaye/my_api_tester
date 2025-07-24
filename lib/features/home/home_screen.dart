// lib/features/home/home_screen.dart
import 'package:flutter/material.dart';
import '../request_panel/request_panel_view.dart';
import '../response_panel/response_panel_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter API Tester'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Row(
        children: [
          // Left Pane: Collections (Placeholder)
          Container(
            width: 250,
            color: Colors.black.withOpacity(0.05),
            child: const Center(child: Text('Collections Panel')),
          ),
          const VerticalDivider(width: 1),

          // Center Pane: Request/Response
          Expanded(
            child: Column(
              children: [
                // <<< FIX START HERE >>>
                // Wrap RequestPanelView in Expanded to give it a bounded height.
                // We'll give it less space (flex: 2) than the response panel.
                const Expanded(
                  flex: 2,
                  child: RequestPanelView(),
                ),

                const Divider(height: 1),

                // ResponsePanelView is already in an Expanded.
                // We'll give it more space (flex: 3).
                const Expanded(
                  flex: 3,
                  child: ResponsePanelView(),
                ),
                // <<< FIX END HERE >>>
              ],
            ),
          ),
        ],
      ),
    );
  }
}