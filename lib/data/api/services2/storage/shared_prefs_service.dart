import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  // Singleton pattern
  static final SharedPrefsService _instance = SharedPrefsService._internal();
  factory SharedPrefsService() => _instance;
  SharedPrefsService._internal();

  // SharedPreferences instance
  SharedPreferences? _prefs;

  // Initialize (call this in main.dart before runApp)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Check if initialized
  bool get isInitialized => _prefs != null;

  // Access the SharedPreferences instance
  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('SharedPrefsService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Convenience methods
  Future<bool> setString(String key, String value) async {
    return prefs.setString(key, value);
  }

  String? getString(String key) {
    return prefs.getString(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return prefs.getBool(key);
  }

  Future<bool> remove(String key) async {
    return prefs.remove(key);
  }

  Future<bool> clear() async {
    return prefs.clear();
  }
}
