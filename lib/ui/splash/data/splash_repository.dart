import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/ui/splash/data/splash_entity.dart';
export 'package:my_wallet/ui/splash/data/splash_entity.dart';

import 'dart:io' show Platform;
import 'package:my_wallet/firebase_config.dart' as fbConfig;
import 'package:my_wallet/data/firebase/database.dart' as fdb;
import 'package:my_wallet/data/firebase/authentication.dart' as auth;

import 'package:firebase_core/firebase_core.dart';

import 'package:my_wallet/data/local/database_manager.dart' as db;

import 'package:package_info/package_info.dart';
import 'package:flutter/services.dart';

class SplashException implements Exception {
  final String code;
  final String message;

  SplashException(this.code, this.message);

  @override
  String toString() {
    return this.message;
  }
}

class SplashRepository extends CleanArchitectureRepository {

  Future<String> loadAppVersion() async {
    PackageInfo info = await PackageInfo.fromPlatform();

    return "v${info.version} - (build ${info.buildNumber})";
  }

  Future<AppDetail> loadAppData() async {
    try {
      FirebaseApp _app = await FirebaseApp.configure(
          name: fbConfig.firebase_app_name,
          options: Platform.isIOS
              ? const FirebaseOptions(
            googleAppID: fbConfig.firebase_ios_app_id,
            gcmSenderID: fbConfig.firebase_gcm_sender_id,
            projectID: fbConfig.firebase_project_id,
            databaseURL: fbConfig.firebase_database_url,
            apiKey: fbConfig.firebase_api_key,
          )
              : const FirebaseOptions(
            googleAppID: fbConfig.firebase_android_app_id,
            apiKey: fbConfig.firebase_api_key,
            projectID: fbConfig.firebase_project_id,
            databaseURL: fbConfig.firebase_database_url,
          ));

      await db.init();

      await auth.init(_app);

      var user = await auth.getCurrentUser();

      var profile;

      if (user != null) {
        var home = await auth.searchUserHome(user);
        if (home != null) profile = home.key;

        if (profile == null) {
          var host = await auth.findHomeOfHost(user.email);
          if (host != null) profile = host.key;
        }
      }

      await fdb.init(_app, homeProfile: profile);

      return AppDetail(
          user != null && user.uuid != null && user.uuid.isNotEmpty,
          user != null && user.isVerified,
          profile != null && profile.isNotEmpty
      );
    } on PlatformException catch(e) {
      throw SplashException(e.code, e.message);
    }
  }
}