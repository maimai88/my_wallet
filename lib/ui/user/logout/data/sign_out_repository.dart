import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/data/local/database_manager.dart' as db;
import 'package:my_wallet/data/firebase/authentication.dart' as fm;
import 'package:my_wallet/data/firebase/database.dart' as fdb;
import 'package:my_wallet/shared_pref/shared_preference.dart';

class SignOutRepository extends CleanArchitectureRepository {
  Future<bool> signOutFromFirebase() {
    return fm.signOut();
  }

   Future<void> deleteDatabase() async {
    return db.dropAllTables();
  }

  Future<void> clearAllPreference() async {
    await SharedPreferences.deleteUserUUID();
    await SharedPreferences.deleteHomeProfile();
  }

  Future<void> unlinkFbDatabase() {
    return fdb.removeReference();
  }
}