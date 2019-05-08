import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';

abstract class SignOutDataView extends DataView {
  void onSignOutSuccess(bool result);
  void onSignOutFailed(Exception exception);
}