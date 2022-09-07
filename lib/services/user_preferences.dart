import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static final UserPreferences _instance = UserPreferences._default();
  factory UserPreferences() {
    return _instance;
  }

  UserPreferences._default();

  late SharedPreferences _preferences;

  init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  get fcmToken {
    return _preferences.getString('fcmToken');
  }

  Future setFcmToken(String value) {
    return _preferences.setString('fcmToken', value);
  }

  Future<bool> deleteFcmToken() {
    return _preferences.remove('fcmToken');
  }

  get location {
    return _preferences.getString('location') ?? "Unknown";
  }

  Future<bool> setLocation(String value) {
    return _preferences.setString('location', value);
  }
}
