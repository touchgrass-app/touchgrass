import 'package:flutter/material.dart';
import '../viewmodels/login_viewmodel.dart';
import '../core/style/fade_route.dart';
import '../core/utils/result.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  final LoginViewmodel viewModel = LoginViewmodel();

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;
  String? _error;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.login.addListener(_onRegister);
  }

  @override
  void didUpdateWidget(covariant LoginScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.login.removeListener(_onRegister);
    widget.viewModel.login.addListener(_onRegister);
  }

  @override
  void dispose() {
    widget.viewModel.login.removeListener(_onRegister);
    super.dispose();
  }

  void _onRegister() {
    if (widget.viewModel.login.completed) {
      widget.viewModel.login.clearResult();
      Navigator.push(
        context,
        FadeRoute(page: HomeScreen()),
      );
    }
    if (widget.viewModel.login.error) {
      Result<dynamic> result = widget.viewModel.login.result!;
      switch (result) {
        case Ok():
          break;
        case Error():
          setState(() {
            _error = result.error.toString().replaceFirst("Exception: ", "");;
          });
          break;
      }
      widget.viewModel.login.clearResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.grass,
                      size: 48,
                      color: Color(0xFF4CAF50),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Welcome to TouchGrass',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Track your habits, touch grass',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF242424),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Username or Email',
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Colors.grey,
                            size: 20,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        controller: _email,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username or email';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF242424),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.grey,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        obscureText: !_showPassword,
                        controller: _password,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(244, 67, 54, 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Colors.red.shade300,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            widget.viewModel.login.execute(
                                (_email.value.text, _password.value.text));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: ListenableBuilder(
                            listenable: widget.viewModel.login,
                            builder: (context, child) {
                              return widget.viewModel.login.running
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white70),
                                      ),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                            }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          FadeRoute(page: RegisterScreen()),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                      ),
                      child: const Text(
                        'Don\'t have an account? Register',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
