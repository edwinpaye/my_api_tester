// lib/features/response_panel/response_panel_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import '../../core/providers/providers.dart';

class ResponsePanelView extends ConsumerWidget {
  const ResponsePanelView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responseAsync = ref.watch(responseStateProvider);
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2, // Body and Headers
      child: Column(
        children: [
          // Metadata bar (Status, Time)
          Container(
            color: Colors.black.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                Text(
                  'Status: ${responseAsync.valueOrNull?.statusCode ?? '...'}',
                  style: TextStyle(
                    color: (responseAsync.valueOrNull?.statusCode ?? 0) >= 400
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
                const Spacer(),
                Text('Time: ${responseAsync.valueOrNull?.timeTaken.inMilliseconds ?? '...'} ms'),
              ],
            ),
          ),
          const TabBar(tabs: [Tab(text: 'Body'), Tab(text: 'Headers')]),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              // Use the switch expression on AsyncValue for clean state handling
              child: switch (responseAsync) {
                AsyncData(:final value) => TabBarView(
                    children: [
                      // Pretty Body View
                      SyntaxView(
                        code: value.body,
                        syntax: Syntax.JAVASCRIPT, // JSON is a subset of JS
                        syntaxTheme: SyntaxTheme.vscodeDark(),
                        expanded: true,
                        withLinesCount: true,
                      ),
                      // Headers View
                      ListView(
                        children: value.headers.entries
                            .map((e) => ListTile(
                                  title: Text(e.key),
                                  subtitle: Text(e.value.toString()),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                AsyncError(:final error) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red))),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ),
        ],
      ),
    );
  }
}