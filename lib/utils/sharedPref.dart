import 'package:shared_preferences/shared_preferences.dart';

// class MySharedPref async {

  // SharedPreferences preferences = await SharedPreferences.getInstance();

  void saveText(String key, String value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(key, value);
    preferences.commit();
  }

  Future<String> readText(String key)  async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var value = preferences.getString(key) ?? "00";
    return value;
  }


  Future<bool> deleteAll()  async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    return true;
  }

// }

