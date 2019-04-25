class LoginException implements Exception {
  final String emailException;
  final String passwordException;
  final String loginException;

  LoginException({this.emailException, this.passwordException, this.loginException});
}