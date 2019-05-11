import 'package:my_wallet/data/local/database_manager.dart' as db;

const tableAccount = db.tblAccount;
const tableTransactions = db.tblTransaction;
const tableCategory = db.tblCategory;
const tableBudget = db.tblBudget;
const tableUser = db.tblUser;
const tableTransfer = db.tblTransfer;
const tableDischargeLiability = db.tblDischargeOfLiability;

abstract class DatabaseObservable {
  void onDatabaseUpdate(List<String> tables);
}

void registerDatabaseObservable(List<String> tables, DatabaseObservable observable) {
  db.registerDatabaseObservable(tables, observable);
}

void unregisterDatabaseObservable(List<String> tables, DatabaseObservable observable) {
  db.unregisterDatabaseObservable(tables, observable);
}


