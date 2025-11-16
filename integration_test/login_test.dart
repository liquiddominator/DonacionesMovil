import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:donaciones_movil/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const testEmail = 'eliasandres2504@gmail.com';
  const testPassword = '123456';

  testWidgets(
    'HU-M1: Login exitoso y navegación al Dashboard',
    (WidgetTester tester) async {
      // 1. Arrancar la app
      app.main();

      // 2. Esperar a que terminen Splash + navegación
      //    (Splash dura ~5s, damos 8s de margen)
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // 3. Buscar los campos de Login
      final emailField = find.byKey(const Key('txtEmailLogin'));
      final passwordField = find.byKey(const Key('txtPasswordLogin'));
      final loginButton = find.byKey(const Key('btnLogin'));

      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(loginButton, findsOneWidget);

      // 4. Llenar credenciales
      await tester.enterText(emailField, testEmail);
      await tester.enterText(passwordField, testPassword);
      await tester.pumpAndSettle();

      // 5. Tap en botón login
      await tester.tap(loginButton);

      // 6. Esperar navegación al Dashboard
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // 7. Verificar Dashboard
      expect(find.byKey(const Key('dashboardPage')), findsOneWidget);
      expect(find.byKey(const Key('lblCampaniasDestacadas')), findsOneWidget);
    },
  );
}