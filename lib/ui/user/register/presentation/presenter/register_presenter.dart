import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';

import 'package:my_wallet/ui/user/register/presentation/view/register_data_view.dart';
import 'package:my_wallet/ui/user/register/domain/register_use_case.dart';

class RegisterPresenter extends CleanArchitecturePresenter<RegisterUseCase, RegisterDataView> {
  RegisterPresenter() : super(RegisterUseCase());

  void registerEmail(String displayName, String email, String password, String confirmPassword) {
    useCase.registerEmail(displayName, email, password, confirmPassword, dataView.onRegisterSuccess, dataView.onRegisterFailed);
  }
}