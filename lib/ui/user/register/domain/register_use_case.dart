import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/user/register/data/register_repository.dart';

class RegisterUseCase extends CleanArchitectureUseCase<RegisterRepository> {
  RegisterUseCase() : super(RegisterRepository());

  void registerEmail(String displayName, String email, String password, String confirmPassword, onNext<bool> next, onError error) {
    execute(Future(() async {
      var result = false;
      do {
        String displayNameError;
        String emailError;
        String passwordError;
        String confirmPasswordError;
        String registerError;

        try {
          await repo.validateDisplayName(displayName);
        } catch(e) {
          if (e is RegisterException) {
            displayNameError = e.displayNameError;
          } else {
            displayNameError = e.toString();
          }
        }

        try {
          await repo.validateEmail(email);
        } catch (e) {
          if (e is RegisterException) {
            emailError = e.emailError;
          } else {
            emailError = e.toString();
          }
        }

        try {
          await repo.validatePassword(password);
        } catch(e) {
          if (e is RegisterException) {
            passwordError = e.passwordError;
          } else {
            passwordError = e.toString();
          }
        }

        try {
          await repo.validateConfirmPassword(password, confirmPassword);
        } catch(e) {
          if (e is RegisterException) {
            confirmPasswordError = e.confirmPasswordError;
          } else {
            confirmPasswordError = e.toString();
          }
        }

        if (displayNameError != null
            || emailError != null
            || passwordError != null
            || confirmPasswordError != null) {
          throw RegisterException(
              displayNameError: displayNameError,
              emailError: emailError,
              passwordError: passwordError,
              confirmPasswordError: confirmPasswordError,
          );
        }

        try {
          await repo.registerEmail(email, password, displayName);
        } catch (e) {
          throw RegisterException(registerError: e.toString());
        }

        User user = await repo.getCurrentUser();

        await repo.saveUserReference(user.uuid);

        await repo.sendVerificationEmail();

        result = true;
      } while (false);

      return result;
    }), next, error);
  }
}