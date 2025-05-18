import 'package:flutter/material.dart';
//import 'package:logging/logging.dart';
import '../models/user.dart';
import '../core/services/auth_service.dart';
import '../core/utils/command.dart';
import '../core/utils/result.dart';



class LoginViewmodel extends ChangeNotifier {
  LoginViewmodel() {
      login = Command1(_login);
  }


  final AuthService _authService = AuthService();
  AuthResponse? _authResponse;
  User? _user;

  AuthResponse? get authResponse => _authResponse;
  User? get user => _user;

  late Command1<void, (String username, String password)> login;


  // private login function
  Future<Result> _login((String, String) cred) async {
    final (username, password) = cred;
    final result = await _authService.login(
    username,
    password,
    );
    notifyListeners();
    return result;
  }

}
