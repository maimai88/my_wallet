import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';
import 'package:my_wallet/ui/account/liability/detail/data/liability_entity.dart';
export 'package:my_wallet/ui/account/liability/detail/data/liability_entity.dart';

abstract class LiabilityDataView extends DataView {
  void onAccountLoaded(LiabilityEntity acc);
  void onAccountLoadError(Exception e);
}