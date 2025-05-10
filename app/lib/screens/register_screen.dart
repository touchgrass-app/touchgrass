import 'package:flutter/material.dart';
import '../viewmodels/register_viewmodel.dart';
import 'dart:math';
import '../core/utils/result.dart';
import '../core/style/fade_route.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key});
  final RegisterViewmodel viewModel = RegisterViewmodel();
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
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.viewModel.register.addListener(_onRegister);
  }
  @override
  void didUpdateWidget(covariant RegisterScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.register.removeListener(_onRegister);
    widget.viewModel.register.addListener(_onRegister);
  }

  @override
  void dispose() {
    widget.viewModel.register.removeListener(_onRegister);
    super.dispose();
  }

  void _generateRandomUser() {
    final random = Random();
    final firstName = 'User${random.nextInt(1000)}';
    final lastName = 'Test${random.nextInt(1000)}';
    _usernameController.text =
        '${firstName.toLowerCase()}${random.nextInt(1000)}';
    _emailController.text = '${_usernameController.text}@example.com';
    _passwordController.text = 'password';
    _confirmPasswordController.text = 'password';
    _firstNameController.text = firstName;
    _lastNameController.text = lastName;

    final now = DateTime.now();
    final randomDays = random.nextInt(365 * 62);
    _dateOfBirth = now.subtract(Duration(days: 365 * 18 + randomDays));

    setState(() {});
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

  String? _validatePassword(String? text) {
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

  String? _validateEmail(String? text) {
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

  String? _validateName(String? text) {
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

  String? _validateUserName(String? text) {
    // regex for only upper,lowercase,'_',numbers
    final _userNameRegex = RegExp(r'^[A-Za-z0-9_]+$');
    String _errorMessage = '';

    if (text == null || text.length < 3 ) {
      _errorMessage += 'text must be longer than 3 characters.\n';
    }
    if (!text!.contains(_userNameRegex)) {
      _errorMessage += ' Username only takes letters, numbers and underscores\n';
    }
    if (_errorMessage.isEmpty){
      return null; // successful validation
    }
    else{
      return _errorMessage;
    }
  }

  // Private function to check if validator is good
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      widget.viewModel.register.execute((
      _usernameController.text,
      _emailController.text,
      _passwordController.text,
      _firstNameController.text.isEmpty
          ? null
          : _firstNameController.text,
      _lastNameController.text.isEmpty
          ? null
          : _lastNameController.text,
      _dateOfBirth?.toIso8601String(),
      ));
    }
  }

  void _onRegister() {
    if (widget.viewModel.register.completed) {
      widget.viewModel.register.clearResult();
      Navigator.push(
        context,
        FadeRoute(page: HomeScreen()),
      );
    }
    if (widget.viewModel.register.error){
      Result<dynamic> result = widget.viewModel.register.result!;
      switch(result){
        case Ok():
          break;
        case Error():
          setState(() {
            _error =result.error.toString().replaceFirst("Exception: ", "");;
          });
          break;
      }
      widget.viewModel.register.clearResult();
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
                        validator: (value) {return _validateUserName(value);},
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
                        validator: (value) {return _validateEmail(value);},
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
                        validator: (value) {return _validatePassword(value);},
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
                    ElevatedButton.icon(
                      onPressed: widget.viewModel.register.running? null:_generateRandomUser,
                      icon: const Icon(Icons.auto_fix_high),
                      label: const Text('Generate Random User'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        onPressed: widget.viewModel.register.running ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: ListenableBuilder(
                        listenable: widget.viewModel.register,
                        builder: (context, child) {
                          return widget.viewModel.register.running
                          ?
                               const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white70),
                                ),
                              )
                          :
                             const Text(
                              'Register',
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
                          FadeRoute(page: LoginScreen()),
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
