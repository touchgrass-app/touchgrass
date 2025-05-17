import 'package:flutter/material.dart';
//import 'package:logging/logging.dart';
import '../models/user.dart';
import '../core/services/auth_service.dart';
import '../core/utils/command.dart';
import '../core/utils/result.dart';



class RegisterViewmodel extends ChangeNotifier {
  RegisterViewmodel(){
    register = Command1(_register);
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
    var result = await _authService.register(
      username,
      email,
      password,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth
    );
    switch (result) {
      case Ok<AuthResponse>():
        result = await _authService.login(username, password);
        break;
      case Error<AuthResponse>():
        break;
    }
    notifyListeners();
  return result;
  }


}
