import 'package:flutter/material.dart';
//import 'package:logging/logging.dart';
import '../models/user.dart';
import '../core/services/auth_service.dart';
import '../core/utils/command.dart';
import '../core/utils/result.dart';



class LoginViewmodel extends ChangeNotifier {
  LoginViewmodel() {
      login = Command0(_login);
  }

  final formKey = GlobalKey<FormState>();
  bool showPassword = false;
  String? error;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  AuthResponse? _authResponse;
  User? _user;

  AuthResponse? get authResponse => _authResponse;
  User? get user => _user;

  late Command0<void> login;


  // private login function
  Future<Result> _login() async {
    final result = await _authService.login(
    emailController.text,
    passwordController.text,
    );
    notifyListeners();
    return result;
  }

}
