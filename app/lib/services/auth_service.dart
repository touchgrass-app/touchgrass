import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../config/api_config.dart';
import '../constants/error_codes/auth_error_codes.dart';
import '../constants/error_codes/user_error_codes.dart';

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

      final errorCode = jsonResponse['error'] as String?;
      if (errorCode != null) {
        final authError = AuthErrorCode.fromString(errorCode);
        if (authError != null) {
          switch (authError) {
            case AuthErrorCode.authenticationError:
              throw 'Invalid credentials';
            case AuthErrorCode.registrationError:
              throw jsonResponse['message'] ?? 'Failed to register';
          }
        }

        final userError = UserErrorCode.fromString(errorCode);
        if (userError != null) {
          switch (userError) {
            case UserErrorCode.userNotFound:
              throw 'User not found';
            case UserErrorCode.permissionDenied:
              throw 'Permission denied';
          }
        }
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

    final authResponse =
        _handleResponse(response, AuthResponse.fromJson, 'Failed to login');
    await _saveToken(authResponse.token);
    return authResponse;
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

    return _handleResponse(
        response, AuthResponse.fromJson, 'Failed to register');
  }

  Future<User> getCurrentUser() async {
    final token = await getToken();
    if (token == null) {
      throw 'Not authenticated';
    }

    final response = await http.get(
      Uri.parse(ApiConfig.me),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return _handleResponse(
        response, User.fromJson, 'Failed to get user details');
  }

  Future<User> getUserByToken(String token) async {
    final response = await http.get(
      Uri.parse(ApiConfig.me),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return User.fromJson(json['data']);
    } else {
      throw Exception('Failed to get user');
    }
  }
}
