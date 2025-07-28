// lib/features/utilities/views/base64_decoder_view.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart'; // We'll add our new provider here

// We no longer need the StateProviders for the inputs.
// The controllers will manage the state locally within the widget.

class Base64DecoderView extends ConsumerStatefulWidget {
  const Base64DecoderView({super.key});

  @override
  ConsumerState<Base64DecoderView> createState() => _Base64DecoderViewState();
}

class _Base64DecoderViewState extends ConsumerState<Base64DecoderView> {
  // Create controllers for each text field.
  late final TextEditingController _filenameController;
  late final TextEditingController _base64Controller;

  @override
  void initState() {
    super.initState();
    // Initialize the controllers.
    // We can set a default filename here.
    _filenameController = TextEditingController(text: 'decoded_file.bin');
    _base64Controller = TextEditingController();
  }

  @override
  void dispose() {
    // Always dispose of controllers to free up resources.
    _filenameController.dispose();
    _base64Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Base64 File Decoder'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input field for the filename
            TextField(
              // Assign the controller
              controller: _filenameController,
              decoration: const InputDecoration(
                labelText: 'Enter Filename (e.g., document.pdf, image.png)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Input field for the Base64 string
            Expanded(
              child: TextField(
                // Assign the controller
                controller: _base64Controller,
                decoration: const InputDecoration(
                  labelText: 'Paste Base64 String Here',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            const SizedBox(height: 16),
            // The action button
            ElevatedButton.icon(
              icon: const Icon(Icons.save_alt),
              label: const Text('Decode and Save As...'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              onPressed: () async {
                // Read the text DIRECTLY from the controllers.
                final base64String = _base64Controller.text;
                final filename = _filenameController.text;

                if (base64String.trim().isEmpty || filename.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filename and Base64 content cannot be empty.')),
                  );
                  return;
                }

                try {
                  // The decoding logic remains the same
                  final Uint8List decodedBytes = base64Decode(base64String.trim());
                  // Call the provider to handle saving
                  await ref.read(saveBytesAsFileProvider)(decodedBytes, filename);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('File saved successfully!')),
                  );
                } on FormatException {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error: Invalid Base64 string. The input is not valid Base64.')),
                  );
                } catch (e) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('An error occurred: $e')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}