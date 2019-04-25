class RegisterException implements Exception {
  String displayNameError;
  String emailError;
  String passwordError;
  String confirmPasswordError;
  String registerError;

  RegisterException({this.displayNameError, this.emailError, this.passwordError, this.confirmPasswordError, this.registerError});
}