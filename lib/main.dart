// lib/main.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'features/home/home_screen.dart';

// void main() {
//   runApp(
//     const ProviderScope(
//       child: MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter API Tester',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//         textTheme: GoogleFonts.interTextTheme(),
//       ),
//       home: const HomeScreen(),
//     );
//   }
// }

// lib/main.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'features/shell/app_shell.dart';

// void main() {
//   // ProviderScope is required for Riverpod to work
//   runApp(const ProviderScope(child: MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Clean API Tester',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//         textTheme: GoogleFonts.interTextTheme(),
//       ),
//       home: const AppShell(),
//     );
//   }
// }

// // lib/main.dart
// import 'package:my_api_tester/core/database/database_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'dart:io';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// import 'features/shell/app_shell.dart';

// Future<void> main() async {
//   // Required for async calls in main
//   WidgetsFlutterBinding.ensureInitialized();

//   // --- NEW INITIALIZATION BLOCK FOR DESKTOP ---
//   // This is the fix. It must be done before any sqflite code is called.
//   if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
//     // Initialize FFI
//     sqfliteFfiInit();
//     // Change the default factory for sqflite to use the FFI factory
//     databaseFactory = databaseFactoryFfi;
//   }
//   // --- END OF NEW INITIALIZATION BLOCK ---

//   // Now, our own database service can be initialized safely on any platform
//   await DatabaseService.instance.init();

//   runApp(const ProviderScope(child: MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Clean API Tester',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//         textTheme: GoogleFonts.interTextTheme(),
//       ),
//       home: const AppShell(),
//     );
//   }
// }
// lib/main.dart
import 'dart:io';
import 'package:path/path.dart' as p; // For joining paths
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:my_api_tester/core/database/database_service.dart';
import 'features/shell/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- THIS IS THE DEFINITIVE INITIALIZATION BLOCK FOR DESKTOP ---
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // 1. Initialize the FFI bindings
    sqfliteFfiInit();

    // 2. Set the database factory to the FFI implementation
    databaseFactory = databaseFactoryFfi;
  }
  // --- END INITIALIZATION BLOCK ---

  // This must be called AFTER setting the factory
  await DatabaseService.instance.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clean API Tester',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const AppShell(),
    );
  }
}