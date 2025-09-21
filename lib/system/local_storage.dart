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
}
