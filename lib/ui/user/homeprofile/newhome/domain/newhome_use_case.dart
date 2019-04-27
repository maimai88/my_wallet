import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/user/homeprofile/newhome/data/newhome_repository.dart';

import 'package:my_wallet/resources.dart' as R;

class NewHomeUseCase extends CleanArchitectureUseCase<NewHomeRepository> {
  NewHomeUseCase() : super(NewHomeRepository());

  void createHomeProfile(String name, onNext<bool> next, onError err) {
    execute(Future(() async {
      // get user to be key of the host of new home
      User host = await repo.getCurrentUser();

      // create this data reference on Firebase database
      String homeKey = await repo.createHome(host, name);

      if(homeKey == null) throw NewHomeException(R.string.failed_to_create_this_new_home);

      // save this key to shared preference
      await repo.saveHome(homeKey, name, host.email);

      await repo.updateDatabaseReference(homeKey);

      await repo.saveUserToHome(host);

      return true;
    }), next, err);
  }

  void joinHomeWithHost(String host, onNext<bool> onJoinSuccess, onError onJoinFailed) {
    execute(Future(() async {
      Home home = await repo.findHomeOfHost(host);

      if(home == null) throw NewHomeException(R.string.host_has_no_home(host));

      User myProfile = await repo.getCurrentUser();

      bool result = await repo.joinHome(home, myProfile);

      if(!result) throw NewHomeException(R.string.failed_to_join_home_with_host(host));

      // save this home key
      await repo.saveHome(home.key, home.name, home.host);

      // and finally update database reference
      await repo.updateDatabaseReference(home.key);

      await repo.saveUserToHome(myProfile);

      return true;
    }), onJoinSuccess, onJoinFailed);
  }
}