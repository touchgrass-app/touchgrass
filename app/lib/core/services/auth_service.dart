import 'dart:convert';
import '../../core/utils/result.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';
import '../../core/config/api_config.dart';
import '../../core/errors/auth_error_codes.dart';
import '../../core/errors/user_error_codes.dart';

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
  static const String _tokenKey = ''; // Value initialised on use

  Result<T> _handleResponse<T>(http.Response response, T Function(Map<String, dynamic> data) parser, String errorMessage) {
    try {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return Result.ok(parser(jsonResponse['data']));
      }
      final errorCode = jsonResponse['error'] as String?;
      if (errorCode != null) {
        final userError = UserErrorCode.fromString(errorCode);
        if (userError != null) {
          switch (userError) {
            case UserErrorCode.userNotFound:
              return Result.error(Exception("User Not Found"));
            case UserErrorCode.permissionDenied:
              return Result.error(Exception("Permission Denied"));
          } // check user errors
        }
        final authError = AuthErrorCode.fromString(errorCode);
        if (authError != null) {
          switch (authError) {
            case AuthErrorCode.authenticationError:
              return Result.error(Exception("Authentication Failed"));
            case AuthErrorCode.registrationError:
              return Result.error(Exception(jsonResponse['message'] ?? 'Failed to register'));
          }
        }// check auth errors
      }
      return Result.error(Exception("Can't parse response"));
    }
    on Exception {
        return Result.error(Exception("Response is not Json"));
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

  Future<Result<void>> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    return const Result.ok(null);
  }

  // Since Login Attempt can fail. it returns a Result<AuthResponse> type
  Future<Result<AuthResponse>> login(String username, String password) async {
    try{
    final response = await http.post(
      Uri.parse(ApiConfig.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    // result is opened to check if _saveToken function needs to be run
    final result = _handleResponse(response, AuthResponse.fromJson, 'Failed to login');
    switch(result){
      case Ok<AuthResponse>():
        await _saveToken(result.value.token);
        return Result.ok(result.value);
      case Error<AuthResponse>():
        return Result.error(result.error);
    }}
    catch (e) {
      return Result.error(Exception('Failed to login'));
    }
  }

  Future<Result<AuthResponse>> register(String username, String email, String password,
      {String? firstName, String? lastName, String? dateOfBirth}) async {
    try {
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
    catch (e){
      return Result.error(Exception('Failed to register'));
    }
  }

  Future<Result<User>> getCurrentUser() async {
    final token = await getToken();
    if (token == null) {
      return Result.error(Exception('Not authenticated'));
    }

    final response = await http.get(
      Uri.parse(ApiConfig.me),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final result = _handleResponse(response, User.fromJson, 'Failed to get user details');
    switch(result){
      case Ok<User>():
        return Result.ok(result.value);
      case Error<User>():
        return Result.error(result.error);
    }
  }

  Future<Result<User>> getUserByToken(String token) async {
    final response = await http.get(
      Uri.parse(ApiConfig.me),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Result.ok(User.fromJson(json['data']));
    } else {
      return Result.error(Exception('Failed to get user'));
    }
  }
}
