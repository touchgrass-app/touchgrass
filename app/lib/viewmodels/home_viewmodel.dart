import 'package:flutter/material.dart';
import '../models/user.dart';
import '../core/services/auth_service.dart';
import '../core/utils/command.dart';
import '../core/utils/result.dart';



class HomeViewmodel extends ChangeNotifier {
  HomeViewmodel(){
    _authService = AuthService();
    logout = Command0(_logout);
    getUser = Command0(_getUser);
    getUser.execute();
  }
  late Command0 logout;
  late Command0 getUser;
  late AuthService _authService;
  AuthResponse? _authResponse;
  User? _user;

  // Sample image URLs - replace with actual post data later
  final List<String> samplePosts = [
    'https://picsum.photos/800/600?random=1',
    'https://picsum.photos/800/600?random=2',
    'https://picsum.photos/800/600?random=3',
    'https://picsum.photos/800/600?random=4',
    'https://picsum.photos/800/600?random=5',
    'https://picsum.photos/800/600?random=6',
    'https://picsum.photos/800/600?random=7',
    'https://picsum.photos/800/600?random=8',
  ];

  AuthService get authService =>  _authService;
  AuthResponse? get authResponse => _authResponse;
  User? get user => _user;
  List<String> get posts => samplePosts;


  Future<Result> _logout() async {
    final result = await _authService.logout();
    notifyListeners();
    return result;
  }
  Future<Result> _getUser() async {
    final result = await _authService.getCurrentUser();
    switch (result) {
      case Ok<User>():
        _user = result.value;
        break;
      case Error():
        break;
    }
    notifyListeners();
    return result;
  }

}
