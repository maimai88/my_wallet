import 'package:my_wallet/ca/data/ca_repository.dart';
import 'package:my_wallet/data/data.dart';
export 'package:my_wallet/data/data.dart';

import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/data/firebase/database.dart' as fdb;

class PayLiabilityRepository extends CleanArchitectureRepository {
  _PayLiabilityDatabaseRepository _dbRepo = _PayLiabilityDatabaseRepository();
  _PayLiabilityFirebaseRepository _fbRepo = _PayLiabilityFirebaseRepository();

  Future<List<Account>> loadAccountsExceptId(int exceptId) {
    return _dbRepo.loadAccountsExceptId(exceptId);
  }

  Future<List<AppCategory>> loadCategories(CategoryType type) {
    return _dbRepo.loadCategories(type);
  }

  Future<int> generateDischargeLiabilityId() {
    return _dbRepo.generateDischargeLiabilityId();
  }

  Future<bool> saveDischargeOfLiability(DischargeOfLiability discharge) {
    _fbRepo.saveDischargeOfLiability(discharge);
    return _dbRepo.saveDischargeOfLiability(discharge);
  }

  Future<bool> saveInterestTransaction(AppTransaction interest) {
    _fbRepo.saveInterestTransaction(interest);

    return _dbRepo.saveInterestTransaction(interest);
  }
}

class _PayLiabilityDatabaseRepository {
  Future<List<Account>> loadAccountsExceptId(int exceptId) {
    return db.queryAccountsExcept([exceptId]);
  }

  Future<List<AppCategory>> loadCategories(CategoryType type) {
    return db.queryCategory(type: type);
  }

  Future<int> generateDischargeLiabilityId() {
    return db.generateDischargeLiabilityId();
  }

  Future<bool> saveDischargeOfLiability(DischargeOfLiability discharge) async {
    return (await db.insertDischargeOfLiability(discharge)) > 0;
  }

  Future<bool> saveInterestTransaction(AppTransaction interest) async {
    return (await db.insertTransaction(interest)) > 0;
  }
}

class _PayLiabilityFirebaseRepository {
  Future<bool> saveDischargeOfLiability(DischargeOfLiability discharge) {
    return fdb.addDischargeOfLiability(discharge);
  }

  Future<bool> saveInterestTransaction(AppTransaction interest) {
    return fdb.addTransaction(interest);
  }
}