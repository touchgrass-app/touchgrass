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
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return AuthResponse.fromJson(jsonResponse['data']);
      }
      throw Exception(jsonResponse['message'] ?? 'Failed to login');
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to login');
    }
  }

  Future<AuthResponse> register(String username, String email, String password,
      {String? firstName, String? lastName, String? dateOfBirth}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
      }),
    );

    print('Register Response Status: ${response.statusCode}');
    print('Register Response Body: ${response.body}');
    print('Register Response Headers: ${response.headers}');

    if (response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return AuthResponse.fromJson(jsonResponse['data']);
      }
      throw Exception(jsonResponse['message'] ?? 'Failed to register');
    } else if (response.statusCode == 403) {
      throw Exception(
          'Access forbidden. Please check if you have the necessary permissions.');
    } else if (response.body.isEmpty) {
      throw Exception(
          'Server returned an empty response with status code: ${response.statusCode}');
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to register');
    }
  }

  Future<User> getUser(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$id'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return User.fromJson(jsonResponse['data']);
      }
      throw Exception(jsonResponse['message'] ?? 'Failed to load user');
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<User> getUserByToken(String token) async {
    print('Fetching user data with token: ${token.substring(0, 10)}...');
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Get User Response Status: ${response.statusCode}');
    print('Get User Response Body: ${response.body}');
    print('Get User Response Headers: ${response.headers}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return User.fromJson(jsonResponse['data']);
      }
      throw Exception(jsonResponse['message'] ?? 'Failed to load user');
    } else {
      throw Exception('Failed to load user');
    }
  }
}
