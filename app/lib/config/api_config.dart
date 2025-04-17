class ApiConfig {
  static String get baseUrl => 'http://localhost:8080/api';

  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get me => '$baseUrl/users/me';
}
