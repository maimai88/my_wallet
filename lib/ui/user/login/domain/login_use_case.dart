import 'package:my_wallet/ui/user/login/data/login_repository.dart';
import 'package:my_wallet/ca/domain/ca_use_case.dart';

class LoginUseCase extends CleanArchitectureUseCase<LoginRepository>{
  LoginUseCase() : super(LoginRepository());

  void signIn(email, password, onNext<LoginResult> onNext, onError onError) {
    execute(Future(() async {
      LoginResult result;
      do {
        String _emailError;

        try {
          await repo.validateEmail(email);
        } catch (e) {
          if (e is LoginException) {
            _emailError = e.emailException;
          } else {
            _emailError = e.toString();
          }
        }

        String _passwordError;
        try {
          await repo.validatePassword(password);
        } catch (e) {
          if (e is LoginException) {
            _passwordError = e.passwordException;
          } else {
            _passwordError = e.toString();
          }
        }

        if(_emailError != null || _passwordError != null) {
          throw LoginException(emailException: _emailError, passwordException: _passwordError);
        }

        User user = await repo.signinToFirebase(email, password);

        if (user == null) break;

        await repo.saveUserReference(user.uuid);

        result = LoginResult(user.displayName, user.isVerified);
      } while(false);
      return result;
    }), onNext, (e) => handleError(onError, e));
  }

  void checkUserHome(onNext<bool> next, onError onError) {
    execute(Future(() async {
      var result = false;
      do {
        // if this user is a host, allow him to go directly into his home. 1 host cannot host more than 1 home
        User user = await repo.getCurrentUser();
        bool isHost = await repo.checkHost(user);

        if (isHost) {
          Home home = await repo.getHome(user.email);

          // save his home to shared pref
          await repo.saveHome(home);

          user = await repo.getUserDetailFromFbDatabase(user.uuid, user);

          // switch database reference
          await repo.switchReference(user.uuid);

          await repo.saveUser(user);

          next(true);

          break;
        }

        result = await repo.checkUserHome();
      } while (false);

      return result;
    }), next, (e) => handleError(onError, e));
  }

  void handleError(onError onError, dynamic e) {
    if( e is LoginException) {
      onError(e);
    } else {
      onError(LoginException(loginException: e.toString()));
    }
  }

  void signInWithGoogle(onNext<bool> next, onError error) {
    execute(Future(() async {
      var result = false;
      do {
        User user = await repo.signInWithGoogle();

        if (user == null) break;

        await repo.saveUserReference(user.uuid);

        result = (user.displayName != null && user.displayName.isNotEmpty);

        return result;
      } while (false);
    }), next, (e) => handleError(error, e));
  }

  void signInWithFacebook(onNext<bool> next, onError error) {
    execute(Future(() async {
      var result = false;
      do {
        User user = await repo.signInWithFacebook();

        if(user == null) break;

        await repo.saveUserReference(user.uuid);

        result = (user.displayName != null && user.displayName.isNotEmpty);
      } while(false);

      return result;
    }), next, (e) => handleError(error, e));
  }
}