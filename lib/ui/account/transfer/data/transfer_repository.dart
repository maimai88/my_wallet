import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/ui/account/transfer/data/transfer_entity.dart';
export 'package:my_wallet/ui/account/transfer/data/transfer_entity.dart';

import 'package:my_wallet/data/local/database_manager.dart' as _db;
import 'package:my_wallet/data/firebase/database.dart' as _fdb;

import 'package:my_wallet/data/data.dart';

class AccountTransferRepository extends CleanArchitectureRepository {
  _AccountTransferDatabaseRepository _dbRepo = _AccountTransferDatabaseRepository();
  _AccountTransferFirebaseRepository _fbRepo = _AccountTransferFirebaseRepository();

  Future<TransferEntity> loadAccountDetails(int fromAccountId) {
    return _dbRepo.loadAccountDetails(fromAccountId);
  }

  Future<int> generateTransferId() {
    return _dbRepo.generateTransferId();
  }

  Future<bool> transferAmount(Transfer transfer) {
    _fbRepo.transferAmount(transfer);
    return _dbRepo.transferAmount(transfer);
  }
}

class _AccountTransferDatabaseRepository {
  Future<TransferEntity> loadAccountDetails(int fromAccountId) async {
    AccountEntity fromAccount;
    List<AccountEntity> toAccounts;

    do {
      // load From account info
      var account = await _db.queryAccount(fromAccountId);

      if(account == null) throw Exception("Account with ID $fromAccountId is invalid");

      fromAccount = AccountEntity(account.id, account.name, await _calculateBalance(account.id, account.initialBalance));

      var accounts = await _db.queryAccountsExcept([fromAccountId]);

      if(accounts != null) {
        toAccounts = [];

        accounts.forEach((f) async {
          toAccounts.add(AccountEntity(f.id, f.name, await _calculateBalance(f.id, f.initialBalance)));
        });
      }
    } while (false);

    return TransferEntity(fromAccount, toAccounts);
  }

  Future<int> generateTransferId() {
    return _db.generateTransferId();
  }

  Future<bool> transferAmount(Transfer transfer) async {
    _db.insertTransfer(transfer);

    return true;
  }

  Future<double> _calculateBalance(int accountId, double initialBalance) async {
    final from = DateTime.fromMillisecondsSinceEpoch(0);
    final to = DateTime.now();

    var spent = await _db.sumAllTransactionBetweenDateByType(from, to, TransactionType.typeExpense);
    var earn = await _db.sumAllTransactionBetweenDateByType(from, to, TransactionType.typeIncome);

    return initialBalance + earn - spent;
  }

}

class _AccountTransferFirebaseRepository {
  Future<bool> transferAmount(Transfer transfer) {
    return _fdb.addTransfer(transfer);
  }
}