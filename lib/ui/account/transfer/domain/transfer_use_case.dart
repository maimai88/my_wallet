import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/account/transfer/data/transfer_repository.dart';
import 'package:my_wallet/shared_pref/shared_preference.dart';

import 'package:my_wallet/data/data.dart' show Transfer;

class AccountTransferUseCase extends CleanArchitectureUseCase<AccountTransferRepository> {
  AccountTransferUseCase() : super(AccountTransferRepository());

  void loadAccountDetails(int fromAccountId, onNext<TransferEntity> next, onError error) {
    execute(repo.loadAccountDetails(fromAccountId), next, error);
  }

  void transferAmount(AccountEntity fromAccount, AccountEntity toAccount, double amount, onNext<bool> next, onError error) {
    execute(Future(() async{
      var id = await repo.generateTransferId();

      var uuid = await SharedPreferences.getUserUUID();

      return repo.transferAmount(Transfer(id, fromAccount.id, toAccount.id, amount, DateTime.now(), uuid));

    }), next, error);
  }
}