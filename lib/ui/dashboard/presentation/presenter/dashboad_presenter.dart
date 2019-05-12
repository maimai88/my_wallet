import 'package:my_wallet/ca/presentation/presenter/ca_presenter.dart';

import 'package:my_wallet/ui/dashboard/domain/dashboard_use_case.dart';

import 'package:my_wallet/ui/dashboard/presentation/view/dashboard_data_view.dart';

class DashboardPresenter extends CleanArchitecturePresenter<DashboardUseCase, DashboardDataView> {
  DashboardPresenter() : super(DashboardUseCase());

  void pauseSubscription() {
    useCase.pauseSubscription();
  }

  void resumeSubscription() {
    useCase.resumeSubscription();
  }
}