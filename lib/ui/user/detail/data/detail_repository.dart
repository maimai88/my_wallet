import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/shared_pref/shared_preference.dart';

import 'package:my_wallet/ui/user/detail/data/detail_entity.dart';
export 'package:my_wallet/ui/user/detail/data/detail_entity.dart';

class UserDetailRepository extends CleanArchitectureRepository {
  Future<UserDetailEntity> loadUserWithUuid(String uuid) async {
    List<User> users =  await db.queryUser(uuid: uuid);

    User user = users == null || users.isEmpty ? null : users[0];

    if(user == null) return null;

    String homeName = await SharedPreferences.getHomeName();
    String homeKey = await SharedPreferences.getHomeProfile();

    String hostDisplayName = "";
    String hostEmail = "";

    if(homeKey ==  uuid) {
      hostEmail = user.email;
      hostDisplayName = user.displayName;
    } else {
      List<User> hostsDetail = await db.queryUser(uuid: homeKey);

      User host = hostsDetail == null || hostsDetail.isEmpty ? null : hostsDetail.first;

      hostEmail = host != null ? host.email : "";
      hostDisplayName = host != null ? host.displayName : "";
    }

    return UserDetailEntity(user.displayName, user.email, user.color, user.photoUrl, homeName, hostEmail, hostDisplayName);
  }
}