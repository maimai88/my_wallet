import 'package:my_wallet/ca/data/ca_repository.dart';
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/ui/account/liability/detail/data/liability_entity.dart';
export 'package:my_wallet/ui/account/liability/detail/data/liability_entity.dart';
import 'package:my_wallet/data/local/database_manager.dart' as db;

class LiabilityRepository extends CleanArchitectureRepository {
  Future<LiabilityEntity> loadAccountInfo(int id) async {
    Account account = await db.queryAccount(id);

    final from = DateTime.fromMillisecondsSinceEpoch(0);
    final to = DateTime.now();
    var spent = await db.sumAllTransactionBetweenDateByType(from, to, TransactionType.typeExpense);
    var earn = await db.sumAllTransactionBetweenDateByType(from, to, TransactionType.typeIncome);

    if(account != null) return LiabilityEntity(
      id,
      account.name,
      account.created,
      account.type.name,
      account.initialBalance,
      account.initialBalance + earn - spent
    );

    throw Exception("Account id $id not found");
  }
}