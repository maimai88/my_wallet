import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/data/local/database_manager.dart' as db;
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/shared_pref/shared_preference.dart';

import 'package:my_wallet/ui/user/detail/data/detail_entity.dart';
export 'package:my_wallet/ui/user/detail/data/detail_entity.dart';

class UserDetailRepository extends CleanArchitectureRepository {
  Future<UserDetailEntity> loadUserWithUuid(String uuid) async {
    User user =  await db.queryUser(uuid);

    if(user == null) return null;

    String homeName = await SharedPreferences.getHomeName();
    String homeKey = await SharedPreferences.getHomeProfile();

    String hostDisplayName = "";
    String hostEmail = "";

    if(homeKey ==  uuid) {
      hostEmail = user.email;
      hostDisplayName = user.displayName;
    } else {
      User host = await db.queryUser(homeKey);

      hostEmail = host != null ? host.email : "";
      hostDisplayName = host != null ? host.displayName : "";
    }

    return UserDetailEntity(user.displayName, user.email, user.color, user.photoUrl, homeName, hostEmail, hostDisplayName);
  }
}