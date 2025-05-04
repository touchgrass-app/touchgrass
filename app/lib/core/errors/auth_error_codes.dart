enum AuthErrorCode {
  authenticationError('AUTHENTICATION_ERROR'),
  registrationError('REGISTRATION_ERROR');

  final String code;
  const AuthErrorCode(this.code);

  static AuthErrorCode? fromString(String code) {
    try {
      return AuthErrorCode.values.firstWhere((e) => e.code == code);
    } catch (e) {
      return null;
    }
  }
}
