import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl => '${dotenv.env['API_BASE_URL']}/api';
  static String get token => '${dotenv.env['API_TOKEN']}';
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get me => '$baseUrl/users/me';
}
