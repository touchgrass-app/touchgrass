import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:touchgrass/screens/home_screen.dart'; // Use the correct import path
import 'package:touchgrass/viewmodels/home_viewmodel.dart'; // Use the correct import path
import 'package:touchgrass/core/utils/result.dart'; // Use the correct import path
import 'package:touchgrass/core/utils/command.dart'; // Use the correct import path
import 'home_screen_test.mocks.dart';

// @GenerateMocks([HomeViewmodel,Command1])
@GenerateMocks([Command0,Command1])
class FakeHomeViewmodel extends HomeViewmodel {
  FakeHomeViewmodel({
    required Command0<void> logout
  }): super(){
    this.logout = logout;
  }
}

void main() {
  // --- Widget Tests for UI Inputs and Button ---
  group('Home Screen Widget Tests', ()
  {
    // late MockHomeViewmodel viewModel;
    late FakeHomeViewmodel viewModel;
    late MockCommand0<void> logout;
    final logoutButton = find.byKey(const ValueKey('LogoutButton'));


    setUp(() {
      logout = MockCommand0();
      viewModel = FakeHomeViewmodel(logout: logout);

      // snub all the command options
      when(logout.execute()).thenAnswer((_) async => const Result.ok('success'));
      when(logout.completed).thenReturn(true);
      when(logout.error).thenReturn(false);
      when(logout.running).thenReturn(false);
    });


    testWidgets(
        'should call viewModel.logout.execute when Logout button is tapped and logout', (
        WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(viewModel: viewModel),
        ),
      );
      // Tap the Home button
      await tester.tap(logoutButton);
      await tester.pump();

      verify(logout.execute()).called(1);
    });
  });
}