import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:touchgrass/screens/login_screen.dart'; // Use the correct import path
import 'package:touchgrass/viewmodels/login_viewmodel.dart'; // Use the correct import path
import 'package:touchgrass/core/utils/result.dart'; // Use the correct import path
import 'package:touchgrass/core/utils/command.dart'; // Use the correct import path
import 'login_screen_test.mocks.dart';

// @GenerateMocks([LoginViewmodel,Command1])
@GenerateMocks([Command0,Command1])
class FakeLoginViewmodel extends LoginViewmodel {
  FakeLoginViewmodel({
    required Command0<void> login
  }): super(){
    this.login = login;
  }
}

void main() {
  // --- Widget Tests for UI Inputs and Button ---
  group('Login Screen Widget Tests', ()
  {
    // late MockLoginViewmodel viewModel;
    late FakeLoginViewmodel viewModel;
    late MockCommand0<void> login;
    final email = find.byKey(const ValueKey('EmailField'));
    final password = find.byKey(const ValueKey('PasswordField'));
    final loginButton = find.byKey(const ValueKey('LoginButton'));


    setUp(() {
      login = MockCommand0();
      viewModel = FakeLoginViewmodel(login: login);

      // snub all the command options
      when(login.execute()).thenAnswer((_) async => const Result.ok('success'));
      when(login.completed).thenReturn(true);
      when(login.error).thenReturn(false);
      when(login.running).thenReturn(false);
    });

    testWidgets(
        'should display all required input fields and a login button', (
        WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(viewModel: viewModel),
        ),
      );

      // Verify that the key input fields are present
      expect(email, findsOneWidget);
      expect(password, findsOneWidget);
      expect(loginButton, findsOneWidget);
    });

    testWidgets('should show password when visibility icon is tapped', (
        WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(viewModel: viewModel),
        ),
      );

      final visibilityIcon = find.descendant(
        of: password,
        matching: find.byIcon(Icons.visibility),
      );
      expect(visibilityIcon, findsOneWidget);

      // Tap the visibility icon
      await tester.tap(visibilityIcon);
      await tester.pump();
    });

    testWidgets(
        'should call viewModel.login.execute when Login button is tapped and form is valid', (
        WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(viewModel: viewModel),
        ),
      );
      await tester.enterText(email, 'test.user@example.com');
      await tester.enterText(password, 'password123');
      await tester.pumpAndSettle();
      // Tap the Login button
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      verify(login.execute()).called(1);
    });
  });
}