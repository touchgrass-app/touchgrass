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

  String? validatePassword(String? text) {
    String _errorMessage = '';
    if (text == null || text.length < 6 ) {
      _errorMessage += 'Password must be longer than 6 characters.\n';
    }
    // if (!text!.contains(RegExp(r'[A-Z]'))) {
    //   _errorMessage += '• Uppercase letter is missing.\n';
    // }
    // if (!text.contains(RegExp(r'[a-z]'))) {
    //   _errorMessage += '• Lowercase letter is missing.\n';
    // }
    // if (!text.contains(RegExp(r'[0-9]'))) {
    //   _errorMessage += '• Digit is missing.\n';
    // }
    // if (!text.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]'))) {
    //   _errorMessage += '• Special character is missing.\n';
    // }

    if (_errorMessage.isEmpty){
      return null; // successful validation
    }
    else{
      return _errorMessage;
    }
  }

  String? validateEmail(String? text) {
    // regex for email in format: first.last@subdomain.domain
    final _emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#"
    r"$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}"
    r"[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}"
    r"[a-zA-Z0-9])?)*$");
    String _errorMessage = '';

    if (text == null || text.length < 6 ) {
      _errorMessage += 'Email must be longer than 6 characters.\n';
    }
    if (!text!.contains(_emailRegex)) {
      _errorMessage += 'Email format error\n';
    }
    if (_errorMessage.isEmpty){
      return null; // successful validation
    }
    else{
      return _errorMessage;
    }
  }

  String? validateName(String? text) {
    // regex for only uppercase,lowercase,'.','''. E.G Donald, O'Connor or J.Trump
    final _nameRegex = RegExp(r"^\\s*([A-Za-z]{1,}([\\.,] |[-\']| ))+[A-Za-z]+\\.?\\s*$");
    String _errorMessage = '';

    if (text == null || text.length < 3 ) {
      _errorMessage += 'Name must be longer than 3 characters.\n';
    }
    if (!text!.contains(_nameRegex)) {
      _errorMessage += ' Name format error\n';
    }
    if (_errorMessage.isEmpty){
      return null; // successful validation
    }
    else{
      return _errorMessage;
    }
  }

  String? validateUserName(String? text) {
    // regex for atleast one letter and only numbers and underscores
    final _userNameRegex = RegExp(r'^(?=.*[A-Za-z])[A-Za-z0-9_]+$');
    String _errorMessage = '';

    if (text == null || text.length < 3 ) {
      _errorMessage += 'text must be longer than 3 characters.\n';
    }
    if (!text!.contains(_userNameRegex)) {
      _errorMessage += ' Username must contain atleast one letter\n'
          ' and only numbers and underscores\n';
    }
    if (_errorMessage.isEmpty){
      return null; // successful validation
    }
    else{
      return _errorMessage;
    }
  }

}
