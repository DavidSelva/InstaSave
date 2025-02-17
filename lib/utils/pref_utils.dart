import 'dart:async' show Future;

import 'package:shared_preferences/shared_preferences.dart';

class PrefUtils {
  static late SharedPreferences _prefsInstance;
  static String PREF_KEY_ID = "id";
  static String PREF_KEY_USER_ID = "user_id";
  static String PREF_KEY_USER_NAME = "user_name";
  static String PREF_KEY_COOKIES = "cookies";
  static String PREF_KEY_ACCESS_TOKEN = "access_token";
  static String PREF_KEY_ACCESS_TOKEN_EXPIRY = "access_token_expiry_date";

  // call this method from iniState() function of mainApp().
  static Future<SharedPreferences> init() async {
    _prefsInstance = await SharedPreferences.getInstance();
    return _prefsInstance;
  }

  static String getString(String key, String defValue) {
    return _prefsInstance.getString(key) ?? defValue ?? "";
  }

  static Future<bool> saveString(String key, String value) async {
    return _prefsInstance.setString(key, value) ?? Future.value(false);
  }

  static Future<bool> saveDouble(String key, double value) async {
    return _prefsInstance.setDouble(key, value);
  }

  static double getDouble(String key, double value) {
    return _prefsInstance.getDouble(key) ?? value;
  }

  static String getHashMap(String key, String defValue) {
    return _prefsInstance.getString(key) ?? defValue ?? "";
  }

  static Future<bool> saveHashMap(String key, String value) async {
    return _prefsInstance.setString(key, value) ?? Future.value(false);
  }

  //deletes..
  static Future<bool> remove(String key) async =>
      await _prefsInstance.remove(key);

  static Future<bool> clear() async => await _prefsInstance.clear();
}
