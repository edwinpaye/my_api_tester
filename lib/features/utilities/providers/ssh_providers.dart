// lib/features/utilities/providers/ssh_providers.dart
import 'dart:async';
import 'dart:convert'; // <-- THE FIX for 'utf8'
import 'dart:io';     // <-- THE FIX for local file operations
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../services/ssh_service.dart';

// ... (sshServiceProvider, sshConnectionStateProvider, sshCurrentPathProvider, sshFileListProvider are unchanged)
enum SshConnectionState { disconnected, connecting, connected, error }
final sshServiceProvider = Provider((ref) => SSHService());
final sshConnectionStateProvider = StateProvider<SshConnectionState>((ref) => SshConnectionState.disconnected);
final sshCurrentPathProvider = StateProvider<String>((ref) => '/');
final sshFileListProvider = FutureProvider.autoDispose<List<SftpName>>((ref) async {
  final isConnected = ref.watch(sshConnectionStateProvider) == SshConnectionState.connected;
  if (!isConnected) return [];
  final sshService = ref.read(sshServiceProvider);
  final currentPath = ref.watch(sshCurrentPathProvider);
  return sshService.listDirectory(currentPath);
});


// --- CORRECTED ACTION PROVIDERS ---

final downloadSshFileProvider = Provider.autoDispose<Future<void> Function(String, String)>((ref) {
  return (remotePath, localFilename) async {
    final service = ref.read(sshServiceProvider);
    final remoteFile = await service.openRemoteFile(remotePath);
    final remoteFileStream = remoteFile.read();

    final localPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Remote File As...',
      fileName: localFilename,
    );

    if (localPath != null) {
      // --- THIS IS THE CORRECTED DOWNLOAD LOGIC ---
      final localFile = File(localPath);
      final sink = localFile.openWrite(); // 1. Open a sink to the local file
      
      // 2. Manually listen to the stream and add each chunk to the sink
      await for (var chunk in remoteFileStream) {
        sink.add(chunk);
      }
      
      // 3. Close the sink to finalize the file on disk
      await sink.close();
      await remoteFile.close(); // Also close the remote file handle
    }
  };
});

final uploadSshFileProvider = Provider.autoDispose<Future<void> Function()>((ref) {
  return () async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null) return;
    final localPath = result.files.single.path!;
    final filename = p.basename(localPath);

    final remoteDir = ref.read(sshCurrentPathProvider);
    final remotePath = p.posix.join(remoteDir, filename);

    final service = ref.read(sshServiceProvider);
    await service.uploadFile(localPath, remotePath);
    
    ref.invalidate(sshFileListProvider);
  };
});

final viewSshFileContentProvider = FutureProvider.autoDispose.family<String, String>((ref, remotePath) async {
  final service = ref.read(sshServiceProvider);
  final bytes = await service.readRemoteFile(remotePath);
  try {
    return utf8.decode(bytes); // 'utf8' is now defined
  } catch (e) {
    throw Exception('This file is not a readable text file.');
  }
});
