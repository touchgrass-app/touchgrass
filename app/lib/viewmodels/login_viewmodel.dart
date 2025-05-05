import 'package:flutter/material.dart';
//import 'package:logging/logging.dart';
import '../models/user.dart';
import '../core/services/auth_service.dart';
import '../core/utils/command.dart';
import '../core/utils/result.dart';



class LoginViewmodel extends ChangeNotifier {
  LoginViewmodel({required AuthService authService}):
      _authService = authService {
      login = Command1(_login);
    // getUser = Command1(_getUser);
  }


  final AuthService _authService;
  AuthResponse? _authResponse;
  User? _user;

  AuthResponse? get authResponse => _authResponse;
  User? get user => _user;

  late Command1<void, (String username, String password)> login;
  // late Command1<void, String> getUser;
  //final _log = Logger('LoginViewModel');


  // private login function
  Future<Result> _login((String, String) cred) async {
    final (username, password) = cred;
    final result = await _authService.login(
    username,
    password,
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
