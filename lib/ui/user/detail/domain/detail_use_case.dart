import 'package:my_wallet/ca/domain/ca_use_case.dart';
import 'package:my_wallet/ui/user/detail/data/detail_repository.dart';

import 'package:my_wallet/shared_pref/shared_preference.dart';

class UserDetailUseCase extends CleanArchitectureUseCase<UserDetailRepository> {
  UserDetailUseCase() : super(UserDetailRepository());

  void loadCurrentUser(onNext<UserDetailEntity> next) async {
    execute(Future(() async {
      String uuid = await SharedPreferences.getUserUUID();

      UserDetailEntity user = await repo.loadUserWithUuid(uuid);

      return user;
    }), next, (e) {
      debugPrint("Load current user error $e");
      next(null);
    });
  }
}