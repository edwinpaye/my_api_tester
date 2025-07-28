// lib/features/utilities/services/ssh_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Import for local file operations
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';

class SSHService {
  SSHClient? _client;
  SftpClient? _sftp;

  bool get isConnected => _client != null && _client!.isClosed == false;

  Future<void> connect({
    required String host,
    required String username,
    required String password,
    int port = 22,
  }) async {
    try {
      _client = SSHClient(
        await SSHSocket.connect(host, port),
        username: username,
        onPasswordRequest: () => password,
      );
      await _client!.authenticated;
      _sftp = await _client!.sftp();
    } catch (e) {
      disconnect();
      rethrow;
    }
  }

  Future<String> getInitialPath() async {
    if (_client == null) throw Exception('Not connected');
    final result = await _client!.run('pwd');
    return utf8.decode(result).trim();
  }

  Future<List<SftpName>> listDirectory(String path) async {
    if (_sftp == null) throw Exception('Not connected');
    return await _sftp!.listdir(path);
  }

  // --- CORRECTED FILE MANAGEMENT METHODS ---

  Future<SftpFile> openRemoteFile(String remotePath) async {
    if (_sftp == null) throw Exception('Not connected');
    return await _sftp!.open(remotePath);
  }

  Future<void> uploadFile(String localPath, String remotePath) async {
    if (_sftp == null) throw Exception('Not connected');
    final remoteFile = await _sftp!.open(
      remotePath,
      mode: SftpFileOpenMode.create | SftpFileOpenMode.write | SftpFileOpenMode.truncate,
    );
    // Read from a local dart:io File and write to the remote file
    final localFile = File(localPath);
    await remoteFile.write(localFile.openRead().cast());
    await remoteFile.close();
  }

  Future<void> deleteFile(String remotePath) async {
    if (_sftp == null) throw Exception('Not connected');
    await _sftp!.remove(remotePath);
  }

  Future<void> deleteDirectory(String remotePath) async {
    if (_sftp == null) throw Exception('Not connected');
    await _sftp!.rmdir(remotePath);
  }

  // Corrected to handle a Stream of bytes and return a single Uint8List
  Future<Uint8List> readRemoteFile(String remotePath) async {
    if (_sftp == null) throw Exception('Not connected');
    final file = await _sftp!.open(remotePath);
    final stream = file.read();

    // Use a BytesBuilder to efficiently collect chunks from the stream.
    final builder = BytesBuilder();
    await for (var chunk in stream) {
      builder.add(chunk);
    }
    await file.close();
    return builder.toBytes();
  }

  void disconnect() {
    _sftp?.close();
    _client?.close();
    _client = null;
    _sftp = null;
  }
}