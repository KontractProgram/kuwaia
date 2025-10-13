import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static Future<bool> checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;
    if(isFirstTime){
      await prefs.setBool('isFirstTime', false);
    }
    return isFirstTime;
  }

  static Future<void> saveSharedUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> sharedUsers = prefs.getStringList('sharedUsers') ?? [];
    if (!sharedUsers.contains(username)) {
      sharedUsers.add(username);
      await prefs.setStringList('sharedUsers', sharedUsers);
    }
  }

  static Future<List<String>> getSharedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('sharedUsers') ?? [];
  }
}
