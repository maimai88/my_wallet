import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/user/logout/data/sign_out_repository.dart';

class SignOutUseCase extends CleanArchitectureUseCase<SignOutRepository> {
  SignOutUseCase() : super(SignOutRepository());

  void signOut(onNext<bool> next, onError error) {
    execute(Future(() async {
      bool signout = await repo.signOutFromFirebase();

      if (signout) {
        // unlink firebase
        await repo.unlinkFbDatabase();

        // clear database
        await repo.deleteDatabase();

        await repo.clearAllPreference();
      }

      return true;
    }), next, error);
  }
}