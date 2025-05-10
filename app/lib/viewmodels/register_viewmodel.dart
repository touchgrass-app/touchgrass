import 'package:flutter/material.dart';
//import 'package:logging/logging.dart';
import '../models/user.dart';
import '../core/services/auth_service.dart';
import '../core/utils/command.dart';
import '../core/utils/result.dart';



class RegisterViewmodel extends ChangeNotifier {
  RegisterViewmodel(){
    register = Command1(_register);
    // getUser = Command1(_getUser);
  }

  final AuthService _authService = AuthService();
  AuthResponse? _authResponse;
  User? _user;

  AuthResponse? get authResponse => _authResponse;
  User? get user => _user;

  late Command1<void, (String, String, String, String?, String?, String?)> register;

  // private register function
  Future<Result> _register((String, String, String, String?, String?, String?) details) async {
    final (username, email, password, firstName, lastName, dateOfBirth) = details;
    final result = await _authService.register(
      username,
      email,
      password,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth
    );
    switch (result) {
      case Ok<AuthResponse>():
        _authResponse = result.value;
        _getUser(_authResponse!.token);
        break;
      case Error():
        break;
    }
    notifyListeners();
    return result;
  }

  // private user function
  Future<Result> _getUser(String token,) async {
    // final (token) = cred;
    final result = await _authService.getUserByToken(
      token,
    );
    switch (result) {
      case Ok<User>():
        _user = result.value;
        break;
      case Error():
        break;
    }
    // notifyListeners(); // not needed anymore
    return result;
  }

}
