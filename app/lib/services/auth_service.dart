import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../config/api_config.dart';

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
  static const String _tokenKey = 'auth_token';

  T _handleResponse<T>(http.Response response,
      T Function(Map<String, dynamic> data) parser, String errorMessage) {
    try {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return parser(jsonResponse['data']);
      }
      throw jsonResponse['message'] ?? errorMessage;
    } catch (e) {
      if (e is String) {
        rethrow;
      }
      throw 'Failed to parse server response';
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<AuthResponse> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200 &&
        jsonDecode(response.body)['success'] == true) {
      final authResponse =
          _handleResponse(response, AuthResponse.fromJson, 'Failed to login');
      await _saveToken(authResponse.token);
      return authResponse;
    }

    // Handle error response
    try {
      final jsonResponse = jsonDecode(response.body);
      print('Login error response: $jsonResponse'); // Debug log
      final errorMessage = jsonResponse['message'] as String?;
      throw errorMessage ?? 'Failed to login';
    } catch (e) {
      if (e is String) {
        rethrow;
      }
      throw 'Failed to login';
    }
  }

  Future<AuthResponse> register(String username, String email, String password,
      {String? firstName, String? lastName, String? dateOfBirth}) async {
    final response = await http.post(
      Uri.parse(ApiConfig.register),
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
      final authResponse = _handleResponse(
          response, AuthResponse.fromJson, 'Failed to register');
      await _saveToken(authResponse.token);
      return authResponse;
    }

    // Handle error response
    try {
      final jsonResponse = jsonDecode(response.body);
      final errorMessage = jsonResponse['message'] as String?;
      throw errorMessage ?? 'Failed to register';
    } catch (e) {
      if (e is String) {
        rethrow;
      }
      throw 'Failed to register';
    }
  }

  Future<User> getUserByToken(String token) async {
    final response = await http.get(
      Uri.parse(ApiConfig.me),
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
