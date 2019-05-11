import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/ui/account/detail/data/detail_entity.dart';
export 'package:my_wallet/ui/account/detail/data/detail_entity.dart';

import 'package:my_wallet/data/local/database_manager.dart' as db;
class AccountDetailRepository extends CleanArchitectureRepository {

  Future<AccountDetailEntity> loadAccount(int accountId) async {
    var account = await db.queryAccount(accountId);

    final fromDate = DateTime.fromMicrosecondsSinceEpoch(0);
    final toDate = DateTime.now();
    var spent = await db.sumAllTransactionBetweenDateByType(fromDate, toDate, TransactionType.typeExpense, accountId: accountId,);
    var earn = await db.sumAllTransactionBetweenDateByType(fromDate, toDate, TransactionType.typeIncome, accountId: accountId, );
    var balance = account.initialBalance + earn - spent;

    if(account != null) return AccountDetailEntity(
      accountId,
      account.name,
      account.created,
      account.type.name,
      balance,
      spent,
      earn
    );

    throw Exception("Account with id $accountId not found");
  }
}