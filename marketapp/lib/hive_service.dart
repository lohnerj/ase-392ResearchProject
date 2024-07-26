import 'package:hive_flutter/hive_flutter.dart';

// Service class for managing Hive operations
class HiveService {
  // Initialize Hive for Flutter
  Future<void> initFlutter() async {
    await Hive.initFlutter();
  }

  // Open a Hive box with the given name
  Future<Box> openBox(String boxName) {
    return Hive.openBox(boxName);
  }
}
