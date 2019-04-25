import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/data/data.dart';
export 'package:my_wallet/data/data.dart';
import 'package:my_wallet/data/firebase/authentication.dart' as fm;

import 'package:my_wallet/ui/user/register/domain/register_exception.dart';
export 'package:my_wallet/ui/user/register/domain/register_exception.dart';

import 'package:flutter/services.dart';
import 'package:my_wallet/utils.dart' as Utils;

import 'package:my_wallet/shared_pref/shared_preference.dart';

class RegisterRepository extends CleanArchitectureRepository {
  _RegisterFirebaseRepository _fbRepo = _RegisterFirebaseRepository();

  Future<bool> validateDisplayName(String name) {
    return _fbRepo.validateDisplayName(name);
  }

  Future<bool> validateEmail(String email) {
    return _fbRepo.validateEmail(email);
  }

  Future<bool> validatePassword(String password) {
    return _fbRepo.validatePassword(password);
  }

  Future<bool> validateConfirmPassword(String password, String confirmPassword) {
    return _fbRepo.validateConfirmPassword(password, confirmPassword);
  }

  Future<bool> registerEmail(String email, String password, String displayName) {
    return _fbRepo.registerEmail(email, password, displayName);
  }

//  Future<bool> updateDisplayName(String displayName)  {
//    return _fbRepo.updateDisplayName(displayName);
//  }

  Future<User> getCurrentUser() {
    return _fbRepo.getCurrentUser();
  }

  Future<void> saveUserReference(String uuid) async {
    return _fbRepo.saveUserReference(uuid);
  }

  Future<void> sendVerificationEmail() {
    return _fbRepo.sendVerificationEmail();
  }
}

class _RegisterFirebaseRepository {
  Future<bool> validateDisplayName(String name) async {
    return name == null || name.isEmpty ? throw RegisterException(displayNameError: "Name must not be empty") : true;
  }

  Future<bool> validateEmail(String email) async {
    if (email == null || email.isEmpty) throw RegisterException(emailError: "Email must not empty");
    if(!Utils.isEmailFormat(email)) throw RegisterException(emailError: "Invalid Email format");

    return true;
  }

  Future<bool> validatePassword(String password) async {
    if(password == null || password.isEmpty) throw RegisterException(passwordError: "Password is empty");
    if(password.length < 6) throw RegisterException(passwordError: "Password is too short");

    return true;
  }

  Future<bool> validateConfirmPassword(String password, String confirmPassword) async {
    if (password == null || password.isEmpty) throw RegisterException(confirmPasswordError: "Password is empty");
    if (password != confirmPassword) throw RegisterException(confirmPasswordError: "Password does not match");

    return true;
  }

  Future<bool> registerEmail(String email, String password, String displayName) async {
    try {
      await fm.registerEmail(email, password, displayName: displayName);
    } on PlatformException catch (e) {
      debugPrint("${e.code} :: ${e.message} :: ${e.toString()}");
      throw RegisterException(registerError : e.message);
    } catch (e) {
      throw RegisterException(registerError : e.toString());
    }

    return true;
  }

  Future<User> getCurrentUser() {
    return fm.getCurrentUser();
  }

  Future<void> saveUserReference(String uuid) {
    return SharedPreferences.setUserUUID(uuid);
  }

  Future<void> sendVerificationEmail() {
    return fm.sendValidationEmail();
  }
}
