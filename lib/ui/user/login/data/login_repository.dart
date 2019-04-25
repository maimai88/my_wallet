import 'package:my_wallet/ca/data/ca_repository.dart';
import 'package:my_wallet/data/firebase/authentication.dart' as fm;
import 'package:my_wallet/data/firebase/database.dart' as fdb;
import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/utils.dart' as Utils;
import 'package:my_wallet/shared_pref/shared_preference.dart';
import 'package:my_wallet/ui/user/login/domain/login_exception.dart';
import 'package:flutter/services.dart';
import 'dart:math';

export 'package:my_wallet/data/data.dart';
export 'package:my_wallet/ui/user/login/domain/login_exception.dart';
export 'package:my_wallet/ui/user/login/data/login_entity.dart';

class LoginRepository extends CleanArchitectureRepository{
  final _LoginFirebaseRepository _fbRepo = _LoginFirebaseRepository();
  final _LoginDatabaseRepository _dbRepo = _LoginDatabaseRepository();

  Future<void> validateEmail(String email) async {
    if (email == null || email.isEmpty) throw LoginException(emailException: "Email is empty");
    if(!Utils.isEmailFormat(email)) throw LoginException(emailException: "Invalid email format");
  }

  Future<void> validatePassword(String password) async {
    if(password == null || password.isEmpty) throw LoginException(passwordException: "Password is empty");
    if(password.length < 6) throw LoginException(passwordException: "Password is too short");
  }

  Future<User> signinToFirebase(String email, String password) {
    return _fbRepo.signInToFirebase(email, password);
  }

  Future<bool> checkHost(User user) {
    return _fbRepo.checkHost(user);
  }

  Future<User> getCurrentUser() {
    return _fbRepo.getCurrentUser();
  }

  Future<Home> getHome(String hostEmail) {
    return _fbRepo.getHome(hostEmail);
  }

  Future<void> saveHome(Home home) async {
    await SharedPreferences.setHomeProfile(home.key);
    await SharedPreferences.setHomeName(home.name);
  }

  Future<void> saveUserReference(String uuid) {
    return SharedPreferences.setUserUUID(uuid);
  }

  Future<void> switchReference(String key) {
    return _fbRepo.switchReference(key);
  }

  Future<void> saveUser(User user) {
    if(user.color == null) return _fbRepo.saveUser(user);
    else return _dbRepo.saveUser(user);
  }

  Future<bool> checkUserHome() async {
    var key = await SharedPreferences.getHomeProfile();

    return key != null && key.isNotEmpty;
  }

  Future<User> getUserDetailFromFbDatabase(String homeKey, User user) {
    return _fbRepo.getUserDetailFromFbDatabase(homeKey, user);
  }

  Future<User> signInWithGoogle() {
    return _fbRepo.signInWithGoogle();
  }

  Future<User> signInWithFacebook() {
    return _fbRepo.signInWithFacebook();
  }
}

class _LoginFirebaseRepository {
  Future<User> signInToFirebase(email, password) async {
    try {
      return await fm.login(email, password);
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      throw LoginException(loginException: "${e.message} ${e.details == null ? "" : e.details}");
    } catch (e) {
      throw e;
    }
  }

  Future<bool> checkHost(User user) {
    return fm.isHost(user);
  }

  Future<void> switchReference(String homeKey) {
    return fdb.setupDatabase(homeKey);
  }

  Future<void> saveUser(User user) {
    return fdb.addUser(user, color: user.color == null ? Random().nextInt(0xFFEEEEEE) : user.color);
  }

  Future<User> getUserDetailFromFbDatabase(String homeKey, User user) {
    return fm.getUserDetail(homeKey, user);
  }

  Future<User> getCurrentUser() {
    return fm.getCurrentUser();
  }

  Future<Home> getHome(String hostEmail) {
    return fm.findHomeOfHost(hostEmail);
  }

  Future<User> signInWithGoogle() {
    return fm.signInWithGoogle();
  }

  Future<User> signInWithFacebook() {
    return fm.signInWithFacebook();
  }
}

class _LoginDatabaseRepository {
  Future<void> saveUser(User user) {
    return db.insertUser(user);
  }
}
