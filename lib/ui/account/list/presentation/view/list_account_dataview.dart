import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';

import 'package:my_wallet/ui/account/list/data/list_account_entity.dart';
export 'package:my_wallet/ui/account/list/data/list_account_entity.dart';

abstract class ListAccountDataView extends DataView {
  void onAccountListLoaded(List<AccountEntity> acc);
}