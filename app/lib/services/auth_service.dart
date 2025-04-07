import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthResponse {
  final String token;
  final String username;

  AuthResponse({required this.token, required this.username});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      username: json['username'] as String,
    );
  }
}

class AuthService {
  static const String baseUrl = 'http://localhost:8080/api';

  T _handleResponse<T>(http.Response response,
      T Function(Map<String, dynamic> data) parser, String errorMessage) {
    try {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return parser(jsonResponse['data']);
      }
      throw Exception(jsonResponse['message'] ?? errorMessage);
    } catch (e) {
      throw Exception('Failed to parse server response: $errorMessage');
    }
  }

  Future<AuthResponse> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return _handleResponse(
          response, AuthResponse.fromJson, 'Failed to login');
    }
    throw Exception('Failed to login');
  }

  Future<AuthResponse> register(String username, String email, String password,
      {String? firstName, String? lastName, String? dateOfBirth}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
      }),
    );

    if (response.statusCode == 201) {
      return _handleResponse(
          response, AuthResponse.fromJson, 'Failed to register');
    }
    throw Exception('Failed to register');
  }

  Future<User> getUserByToken(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return _handleResponse(
          response, User.fromJson, 'Failed to load user data');
    }
    throw Exception('Failed to load user data');
  }
}
