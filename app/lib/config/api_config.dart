import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
  
  // API Endpoints
  static String get login => '$baseUrl/api/login';
} 