import 'package:my_wallet/ca/data/ca_repository.dart';
import 'package:my_wallet/data/firebase/authentication.dart' as fm;
import 'package:my_wallet/data/firebase/database.dart' as fdb;
import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/shared_pref/shared_preference.dart';

class LeftDrawerRepository extends CleanArchitectureRepository {
  final _LeftDrawerFirebaseRepository _fbRepo = _LeftDrawerFirebaseRepository();
  final _LeftDrawerDatabaseRepository _dbRepo = _LeftDrawerDatabaseRepository();
  Future<bool> signOut() {
    return fm.signOut();
  }

  Future<void> clearAllPreference() async {
    await SharedPreferences.deleteUserUUID();
    await SharedPreferences.deleteHomeProfile();
  }

  Future<void> deleteDatabase() async {
    return _dbRepo.deleteDatabase();
  }

  Future<void> unlinkFbDatabase() async {
    return _fbRepo.unlinkFbDatabase();
  }
}

class _LeftDrawerFirebaseRepository {
  Future<bool> signOut() {
    return fm.signOut();
  }

  Future<void> unlinkFbDatabase() async {
    return fdb.removeReference();
  }
}

class _LeftDrawerDatabaseRepository {
  Future<void> deleteDatabase() {
    return db.dropAllTables();
  }
}