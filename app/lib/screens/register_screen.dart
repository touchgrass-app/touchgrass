import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/fade_route.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  DateTime? _dateOfBirth;
  final _authService = AuthService();
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_updateState);
    _emailController.addListener(_updateState);
    _passwordController.addListener(_updateState);
    _confirmPasswordController.addListener(_updateState);
    _firstNameController.addListener(_updateState);
    _lastNameController.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    _usernameController.removeListener(_updateState);
    _emailController.removeListener(_updateState);
    _passwordController.removeListener(_updateState);
    _confirmPasswordController.removeListener(_updateState);
    _firstNameController.removeListener(_updateState);
    _lastNameController.removeListener(_updateState);
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        final user = await _authService.register(
          _usernameController.text,
          _emailController.text,
          _passwordController.text,
          firstName: _firstNameController.text.isEmpty
              ? null
              : _firstNameController.text,
          lastName: _lastNameController.text.isEmpty
              ? null
              : _lastNameController.text,
          dateOfBirth: _dateOfBirth?.toIso8601String(),
        );

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          FadeRoute(page: HomeScreen(user: user)),
        );
      } catch (e) {
        setState(() {
          _error = e.toString();
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
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
                      'Create Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Join TouchGrass and start tracking',
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
                        controller: _usernameController,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Username',
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
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          if (value.length < 3) {
                            return 'Username must be at least 3 characters';
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
                        controller: _emailController,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Colors.grey,
                            size: 20,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
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
                        controller: _passwordController,
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
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        obscureText: !_showPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
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
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
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
                              _showConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _showConfirmPassword = !_showConfirmPassword;
                              });
                            },
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        obscureText: !_showConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
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
                        controller: _firstNameController,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'First Name (Optional)',
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
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF242424),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: _lastNameController,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Last Name (Optional)',
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
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF242424),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: TextFormField(
                          controller: TextEditingController(
                            text: _dateOfBirth == null
                                ? ''
                                : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
                          ),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth (Optional)',
                            labelStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                              size: 20,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(context),
                        ),
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
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white70),
                                ),
                              )
                            : const Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          FadeRoute(page: const LoginScreen()),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                      ),
                      child: const Text(
                        'Already have an account? Login',
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
