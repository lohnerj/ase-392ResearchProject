import 'package:flutter/material.dart';
import 'search_page.dart';
import 'hive_service.dart';

Future<void> main() async {
  // Ensures that Flutter binding is initialized before any other bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive service and open the items box
  HiveService hiveService = HiveService();
  await hiveService.initFlutter();
  await hiveService.openBox('itemsBox');

  // Run the Flutter application
  runApp(const MyApp());
}

// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Market App',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Set the primary color of the app
        visualDensity: VisualDensity
            .adaptivePlatformDensity, // Adaptive density for different platforms
      ),
      home: const SearchPage(), // Set the home screen of the app
    );
  }
}
