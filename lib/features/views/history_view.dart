// lib/features/views/history_view.dart
import 'package:flutter/material.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('History View', style: TextStyle(fontSize: 32)),
      ),
    );
  }
}