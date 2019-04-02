export 'package:my_wallet/ui/home2/data/home2_entity.dart';
import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';
import 'package:my_wallet/ui/home2/data/home2_entity.dart';

abstract class MyWalletHomeDataView extends DataView {
  void onExpensesDetailLoaded(HomeEntity value);
  void onResumeDone(bool result);
}