import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';

import 'package:my_wallet/ui/user/logout/domain/sign_out_use_case.dart';
import 'package:my_wallet/ui/user/logout/presentation/view/sign_out_data_view.dart';

class SignOutPresenter extends CleanArchitecturePresenter<SignOutUseCase, SignOutDataView> {
  SignOutPresenter() : super(SignOutUseCase());

  void signOut() {
    useCase.signOut(dataView.onSignOutSuccess, dataView.onSignOutFailed);
  }
}