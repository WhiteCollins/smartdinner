// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:smartdinner/main.dart';

void main() {
  testWidgets('SmartDinner app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the splash screen loads with SmartDinner title.
    expect(find.text('SmartDinner'), findsOneWidget);
    expect(find.text('Sistema Inteligente para Restaurantes'), findsOneWidget);

    // Verify that the "Comenzar" button is present.
    expect(find.text('Comenzar'), findsOneWidget);

    // Tap the "Comenzar" button to navigate to login.
    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();

    // Verify that we're now on the login screen.
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Usuarios de Prueba'), findsOneWidget);
  });
}
