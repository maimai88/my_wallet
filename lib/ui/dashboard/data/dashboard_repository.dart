import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/data/firebase/database.dart' as fb;

class DashboardRepository extends CleanArchitectureRepository {
  void pauseFirebaseSubscription() {
    fb.dispose();
  }

  void resumeSubscription() {
    fb.resume();
  }
}