// lib/features/utilities/views/ssh_explorer_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:dartssh2/dartssh2.dart';
import '../providers/ssh_providers.dart';

class SshExplorerView extends ConsumerStatefulWidget {
  const SshExplorerView({super.key});
  @override
  ConsumerState<SshExplorerView> createState() => _SshExplorerViewState();
}
class _SshExplorerViewState extends ConsumerState<SshExplorerView> {
  final _hostController = TextEditingController(text: 'test.rebex.net');
  final _portController = TextEditingController(text: '22');
  final _userController = TextEditingController(text: 'demo');
  final _passController = TextEditingController(text: 'password');

  @override
  void dispose() {
    ref.read(sshServiceProvider).disconnect();
    _hostController.dispose();
    _portController.dispose();
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }
  
  Future<void> _connect() async {
    final stateNotifier = ref.read(sshConnectionStateProvider.notifier);
    final pathNotifier = ref.read(sshCurrentPathProvider.notifier);
    final service = ref.read(sshServiceProvider);
    stateNotifier.state = SshConnectionState.connecting;
    try {
      await service.connect(host: _hostController.text, port: int.parse(_portController.text), username: _userController.text, password: _passController.text);
      final initialPath = await service.getInitialPath();
      pathNotifier.state = initialPath;
      stateNotifier.state = SshConnectionState.connected;
    } catch (e) {
      stateNotifier.state = SshConnectionState.error;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connection failed: $e')));
    }
  }

  void _disconnect() {
    ref.read(sshServiceProvider).disconnect();
    ref.read(sshConnectionStateProvider.notifier).state = SshConnectionState.disconnected;
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(sshConnectionStateProvider);
    final fileListAsync = ref.watch(sshFileListProvider);
    final currentPath = ref.watch(sshCurrentPathProvider);
    final pathNotifier = ref.read(sshCurrentPathProvider.notifier);
    final isConnected = connectionState == SshConnectionState.connected;
    final pathContext = p.Context(style: p.Style.posix);

    return Scaffold(
      appBar: AppBar(
        title: Text(isConnected ? 'SSH: $currentPath' : 'SSH Explorer'),
        centerTitle: false,
        actions: [
          if (isConnected) IconButton(icon: const Icon(Icons.upload_file), tooltip: 'Upload File', onPressed: () async { try { await ref.read(uploadSshFileProvider)(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File uploaded successfully!'))); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e'))); } },),
          if (isConnected) TextButton.icon(icon: const Icon(Icons.arrow_upward), label: const Text('Up'), onPressed: () { final parentPath = pathContext.dirname(currentPath); if (parentPath != currentPath) { pathNotifier.state = parentPath; } },),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          if (!isConnected) Padding(padding: const EdgeInsets.all(8.0), child: Column(children: [ Row(children: [ Expanded(child: TextField(controller: _hostController, decoration: const InputDecoration(labelText: 'Host'))), const SizedBox(width: 8), SizedBox(width: 80, child: TextField(controller: _portController, decoration: const InputDecoration(labelText: 'Port'))), ]), Row(children: [ Expanded(child: TextField(controller: _userController, decoration: const InputDecoration(labelText: 'Username'))), const SizedBox(width: 8), Expanded(child: TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: 'Password'))), ]), const SizedBox(height: 8), ElevatedButton(onPressed: connectionState == SshConnectionState.connecting ? null : _connect, child: connectionState == SshConnectionState.connecting ? const CircularProgressIndicator() : const Text('Connect')), ],)),
          if (isConnected) ListTile(title: const Text('Connected', style: TextStyle(color: Colors.green)), subtitle: Text('${_userController.text}@${_hostController.text}'), trailing: TextButton(onPressed: _disconnect, child: const Text('Disconnect'))),
          const Divider(),
          Expanded(
            child: fileListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error listing files: $err')),
              data: (files) {
                final displayFiles = files.where((f) => f.filename != '.' && f.filename != '..').toList();
                displayFiles.sort((a, b) { if (a.attr.isDirectory && !b.attr.isDirectory) return -1; if (!a.attr.isDirectory && b.attr.isDirectory) return 1; return a.filename.compareTo(b.filename); });
                return ListView.builder(
                  itemCount: displayFiles.length,
                  itemBuilder: (context, index) {
                    final file = displayFiles[index];
                    final isDir = file.attr.isDirectory;
                    final remotePath = pathContext.join(currentPath, file.filename);
                    return ListTile(
                      leading: Icon(isDir ? Icons.folder : Icons.article_outlined),
                      title: Text(file.filename),
                      onTap: () { if (isDir) { pathNotifier.state = remotePath; } else { _showFileViewerDialog(context, remotePath); } },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 80, child: Text(isDir ? '' : '${((file.attr.size ?? 0) / 1024).toStringAsFixed(2)} KB', textAlign: TextAlign.end,)),
                          IconButton(icon: const Icon(Icons.more_vert), tooltip: 'More options', onPressed: () => _showContextMenu(context, ref, file, remotePath)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context, WidgetRef ref, SftpName file, String remotePath) {
    final isDir = file.attr.isDirectory;
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.download), title: const Text('Download'),
            onTap: () async { Navigator.pop(context); try { await ref.read(downloadSshFileProvider)(remotePath, file.filename); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download started.'))); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e'))); } },
          ),
          if (!isDir) ListTile(leading: const Icon(Icons.visibility), title: const Text('View as Text'), onTap: () { Navigator.pop(context); _showFileViewerDialog(context, remotePath); },),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red[700]), title: Text('Delete', style: TextStyle(color: Colors.red[700])),
            onTap: () async { Navigator.pop(context); final confirm = await _showConfirmDialog(context, 'Delete ${file.filename}?'); if (confirm == true) { try { final service = ref.read(sshServiceProvider); if (isDir) { await service.deleteDirectory(remotePath); } else { await service.deleteFile(remotePath); } ref.invalidate(sshFileListProvider); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${file.filename} deleted.'))); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e'))); } } },
          ),
        ],
      ),
    );
  }

  void _showFileViewerDialog(BuildContext context, String remotePath) {
    showDialog(context: context, builder: (context) => Dialog(child: SizedBox(width: MediaQuery.of(context).size.width * 0.7, height: MediaQuery.of(context).size.height * 0.7, child: Column(children: [ AppBar(title: Text(p.basename(remotePath)), automaticallyImplyLeading: false, actions: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))]), Expanded(child: Consumer(builder: (context, ref, child) { final contentAsync = ref.watch(viewSshFileContentProvider(remotePath)); return contentAsync.when(loading: () => const Center(child: CircularProgressIndicator()), error: (err, stack) => Center(child: SelectableText('Error: $err')), data: (content) => SingleChildScrollView(padding: const EdgeInsets.all(16), child: SelectableText(content)),); })) ],),),),);
  }

  Future<bool?> _showConfirmDialog(BuildContext context, String title) {
    return showDialog<bool>(context: context, builder: (context) => AlertDialog(title: Text(title), content: const Text('This action cannot be undone.'), actions: [ TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Delete')), ],),);
  }
}