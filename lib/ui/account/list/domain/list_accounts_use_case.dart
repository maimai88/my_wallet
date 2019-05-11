import 'package:my_wallet/ui/account/list/data/list_accounts_repository.dart';
import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/account/list/data/list_account_entity.dart';

class ListAccountsUseCase extends CleanArchitectureUseCase<ListAccountsRepository>{
  ListAccountsUseCase() : super(ListAccountsRepository());

  void loadAllAccounts(onNext<List<AccountEntity>> next) {
    execute(repo.loadAllAccounts(), next, (e) {
      debugPrint("onLoadAccount error $e");
      next([]);
    });
  }

//  void deleteAccount(int id, onNext<bool> next) {
//    execute<bool>(Future(() async {
//      if(acc != null && acc.id != null) {
//        List<AppTransaction> transactions = await repo.loadAllTransaction(acc.id);
//        List<Transfer> transfers = await repo.loadAllTransfers(acc.id);
//
//        repo.deleteAccount(acc, transactions, transfers);
//      }
//    }), next, (e) {
//      debugPrint("Delete account error");
//      next(false);
//    });
//  }
}