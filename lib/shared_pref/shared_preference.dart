import 'package:flutter_keychain/flutter_keychain.dart';

class SharedPreferences {

  static const keyTargetSaving = "_keyTargetSaving";

  static const _UserUUID = "_UserUUID";
  static const _prefHomeProfile = "_HomeProfile";
  static const _prefHomeName = "_HomeName";
  static const _prefHostEmail = "_HostEmail";

  static const _prefIdToken = "prefIdToken";

  static const _prefPausedTime = "prefPausedTime";

  static Future<void> saveRefreshToken(String token) {
    return FlutterKeychain.put(key: _prefIdToken, value: token);
  }

  static Future<String> getRefreshToken() {
    return FlutterKeychain.get(key: _prefIdToken);
  }

  static Future<void> deleteToken() {
    return FlutterKeychain.remove(key: _prefIdToken);
  }

  static Future<void> setPausedTime(int paused) {
    return FlutterKeychain.put(key: _prefPausedTime, value: "$paused");
  }

  static Future<int> getPausedTime() async {
    var paused = await FlutterKeychain.get(key: _prefPausedTime);

    return paused == null ? null : int.parse(paused);
  }

  static Future<void> setUserUUID(String uuid) {
    return FlutterKeychain.put(key: _UserUUID, value: uuid);
  }

  static Future<String> getUserUUID() {
    return FlutterKeychain.get(key: _UserUUID);
  }

  static Future<void> deleteUserUUID() {
    return FlutterKeychain.remove(key: _UserUUID);
  }

  static Future<void> deleteHomeProfile() {
    return FlutterKeychain.remove(key: _prefHomeProfile);
  }

  static Future<String> getHomeName() {
    return FlutterKeychain.get(key: _prefHomeName);
  }

  static Future<void> setHomeName(String homeName) {
    return FlutterKeychain.put(key: _prefHomeName, value: homeName);
  }

  static Future<String> getHomeProfile() {
    return FlutterKeychain.get(key: _prefHomeProfile);
  }

  static Future<void> setHomeProfile(String homeProfile) {
    return FlutterKeychain.put(key: _prefHomeProfile, value: homeProfile);
  }

  static Future<String> getHostEmail() {
    return FlutterKeychain.get(key: _prefHostEmail);
  }

  static Future<void> setHostEmail(String hostEmail) {
    return FlutterKeychain.put(key: _prefHostEmail, value: hostEmail);
  }
}