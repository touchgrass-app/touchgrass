import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touchgrass/core/services/auth_service.dart';
import 'package:touchgrass/screens/register_screen.dart'; // Use the correct import path
import 'package:touchgrass/viewmodels/register_viewmodel.dart'; // Use the correct import path
import 'package:touchgrass/core/utils/result.dart'; // Use the correct import path
import 'package:touchgrass/core/utils/command.dart'; // Use the correct import path
import 'register_screen_test.mocks.dart';

// @GenerateMocks([RegisterViewmodel,Command1])
@GenerateMocks([Command1])
class FakeRegisterViewmodel extends RegisterViewmodel {
  FakeRegisterViewmodel({
    required Command1<void, (String, String, String, String?, String?, String?)> register
  }): super(){
    this.register = register;
  }
}

void main() {
  // --- Widget Tests for UI Inputs and Button ---
  group('Register Screen Widget Tests', ()
  {
    // late MockRegisterViewmodel viewModel;
    late FakeRegisterViewmodel viewModel;
    late MockCommand1<void, (String, String, String, String?, String?, String?)> register;
    final username = find.byKey(const ValueKey('UsernameField'));
    final email = find.byKey(const ValueKey('EmailField'));
    final password = find.byKey(const ValueKey('PasswordField'));
    final confirmPassword = find.byKey(const ValueKey('ConfirmPasswordField'));
    final registerButton = find.byKey(const ValueKey('RegisterButton'));
    const testDetails = ("testuser123", "test.user@example.com", "password123", null, null, null);


    setUp(() {
      register = MockCommand1();
      viewModel = FakeRegisterViewmodel(register: register);

      // when(viewModel.register.execute(testDetails)).thenAnswer((_) async => <void>[]);
      // when(viewModel.register.completed).thenReturn(true);
      // when(viewModel.register.error).thenReturn(true);
      // when(viewModel.register.clearResult()).thenReturn(null);
      // when(viewModel.register).thenReturn(register);
      // when(viewModel.validateUserName(any)).thenReturn(null);
      // when(viewModel.validatePassword(any)).thenReturn(null);
      // when(viewModel.validateEmail(any)).thenReturn(null);

      when(register.execute(any)).thenAnswer((_) async => const Result.ok('success'));
      when(register.completed).thenReturn(true);
      when(register.error).thenReturn(false);
      when(register.running).thenReturn(false);
    });

    testWidgets(
        'should display all required input fields and a register button', (
        WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RegisterScreen(viewModel: viewModel),
        ),
      );

      // Verify that the key input fields are present
      expect(username, findsOneWidget);
      expect(email, findsOneWidget);
      expect(password, findsOneWidget);
      expect(confirmPassword, findsOneWidget);
      expect(registerButton, findsOneWidget);
      // Optional Widgets
      expect(find.text('First Name (Optional)'), findsOneWidget);
      expect(find.text('Last Name (Optional)'), findsOneWidget);
      expect(find.text('Date of Birth (Optional)'), findsOneWidget);
    });

    testWidgets('should show password when visibility icon is tapped', (
        WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RegisterScreen(viewModel: viewModel),
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

    testWidgets('should show confirm password when visibility icon is tapped', (
        WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RegisterScreen(viewModel: viewModel),
        ),
      );


      final visibilityIcon = find.descendant(
        of: confirmPassword,
        matching: find.byIcon(Icons.visibility),
      );
      expect(visibilityIcon, findsOneWidget);

      // Tap the visibility icon
      await tester.tap(visibilityIcon);
      await tester.pump();

    });

    testWidgets(
        'should call viewModel.register.execute when Register button is tapped and form is valid', (
        WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RegisterScreen(viewModel: viewModel),
        ),
      );
      await tester.enterText(username, 'testuser123');
      await tester.enterText(email, 'test.user@example.com');
      await tester.enterText(password, 'password123');
      await tester.enterText(confirmPassword, 'password123');

      final scrollableFinder = find.byType(SingleChildScrollView);
      expect(scrollableFinder, findsOneWidget);
      await tester.drag(scrollableFinder, const Offset(0, -200));
      await tester.pumpAndSettle();
      // Tap the Register button
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      verify(register.execute(any)).called(1);
    });

    //TODO: Create multiple combinations of invalid input and test for each
    testWidgets(
        'should not call viewModel.register.execute when Register button is tapped and form is invalid', (
        WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RegisterScreen(viewModel: viewModel),
        ),
      );
      await tester.enterText(username, '123');
      await tester.enterText(email, 'test.user@example.com');
      await tester.enterText(password, 'password123');
      await tester.enterText(confirmPassword, 'password123');

      final scrollableFinder = find.byType(SingleChildScrollView);
      expect(scrollableFinder, findsOneWidget);
      await tester.drag(scrollableFinder, const Offset(0, -200));
      await tester.pumpAndSettle();
      // Tap the Register button
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      verifyNever(register.execute(any));
    });
  });
}