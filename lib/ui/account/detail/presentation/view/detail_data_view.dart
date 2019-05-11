import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';

import 'package:my_wallet/ui/account/detail/data/detail_entity.dart';
export 'package:my_wallet/ui/account/detail/data/detail_entity.dart';

abstract class AccountDetailDataView extends DataView {
  void onAccountLoaded(AccountDetailEntity account);
  void failedToLoadAccount(Exception ex);
}