import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';
export 'package:my_wallet/ui/user/register/domain/register_exception.dart';

abstract class RegisterDataView extends DataView {
  void onRegisterSuccess(bool result);
  void onRegisterFailed(Exception e);
}