import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';

import 'package:my_wallet/ui/home2/presentation/view/home2_data_view.dart';
import 'package:my_wallet/ui/home2/domain/home2_use_case.dart';

class MyWalletHomePresenter extends CleanArchitecturePresenter<MyWalletHomeUseCase, MyWalletHomeDataView> {
  MyWalletHomePresenter() : super(MyWalletHomeUseCase());

  void loadExpense() {
    return useCase.loadExpense(dataView.onExpensesDetailLoaded);
  }

  void resumeDatabase() {
    useCase.resumeDatabase(dataView.onResumeDone);
  }
}