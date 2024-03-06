import 'dart:async' show Future;

import 'package:shared_preferences/shared_preferences.dart';

class PrefUtils {
  static SharedPreferences _prefsInstance;
  static String? USER_ID = null;

  // call this method from iniState() function of mainApp().
  static Future<SharedPreferences> init() async {
    _prefsInstance = await SharedPreferences.getInstance();
    return _prefsInstance;
  }

  static String getString(String key, String defValue) {
    return _prefsInstance.getString(key) ?? defValue ?? "";
  }

  static Future<bool> setString(String key, String value) async {
    return _prefsInstance.setString(key, value) ?? Future.value(false);
  }

  //deletes..
  static Future<bool> remove(String key) async =>
      await _prefsInstance.remove(key);

  static Future<bool> clear() async => await _prefsInstance.clear();
}
