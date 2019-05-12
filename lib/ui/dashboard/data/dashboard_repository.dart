import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/data/firebase/database.dart' as fb;
import 'package:my_wallet/data/local/database_manager.dart' as db;

class DashboardRepository extends CleanArchitectureRepository {
  void pauseFirebaseSubscription() {
    fb.dispose();
    db.dispose();
  }

  void resumeSubscription() {
    fb.resume();
    db.resume();
  }
}