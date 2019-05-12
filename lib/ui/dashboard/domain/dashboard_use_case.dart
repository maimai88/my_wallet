import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/dashboard/data/dashboard_repository.dart';

class DashboardUseCase extends CleanArchitectureUseCase<DashboardRepository> {
  DashboardUseCase() : super(DashboardRepository());

  void pauseSubscription() {
    repo.pauseFirebaseSubscription();
  }

  void resumeSubscription() {
    repo.resumeSubscription();
  }
}