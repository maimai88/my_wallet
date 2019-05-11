import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/account/detail/data/detail_repository.dart';

class AccountDetailUseCase extends CleanArchitectureUseCase<AccountDetailRepository> {
  AccountDetailUseCase() : super(AccountDetailRepository());

  void loadAccount(int accountId, onNext<AccountDetailEntity> next, onError error) {
    execute(repo.loadAccount(accountId), next, error);
  }
}