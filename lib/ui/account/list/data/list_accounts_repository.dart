import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/ui/account/list/data/list_account_entity.dart';
import 'package:my_wallet/data/local/database_manager.dart' as db;
import 'package:my_wallet/ca/data/ca_repository.dart';

class ListAccountsRepository extends CleanArchitectureRepository {
  final _ListAccountsDatabaseRepository _dbRepo = _ListAccountsDatabaseRepository();

  Future<List<AccountEntity>> loadAllAccounts() async {
    List<Account> accounts = await _dbRepo.loadAllAccounts();

    List<AccountEntity> entities = [];

    if(accounts != null) {

      final from = DateTime.fromMillisecondsSinceEpoch(0);
      final to = DateTime.now();

      for(Account account in accounts) {
        var spent = await db.sumAllTransactionBetweenDateByType(from, to, TransactionType.typeExpense, accountId: account.id);
        var earn = await db.sumAllTransactionBetweenDateByType(from, to, TransactionType.typeIncome, accountId: account.id);

        entities.add(AccountEntity(
            account.id,
            account.name,
            account.type.name,
            account.initialBalance + earn - spent,
            spent,
            account.type == AccountType.liability
        ));

      }

    }

    return entities;
  }
}

class _ListAccountsDatabaseRepository {
  Future<List<Account>> loadAllAccounts() async {
    return await db.queryAccounts();
  }

  Future<List<AppTransaction>> loadAllTransaction(int accountId) {
    return db.queryTransactions(accountId: accountId);
  }

  Future<List<Transfer>> loadAllTransfers(int accountId) {
    return db.queryTransfer(account: accountId);
  }
}