enum UserErrorCode {
  userNotFound('USER_NOT_FOUND'),
  permissionDenied('PERMISSION_DENIED');

  final String code;
  const UserErrorCode(this.code);

  static UserErrorCode? fromString(String code) {
    try {
      return UserErrorCode.values.firstWhere((e) => e.code == code);
    } catch (e) {
      return null;
    }
  }
}
