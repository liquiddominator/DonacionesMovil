import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:donaciones_movil/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const testEmail = 'eliasandres2504@gmail.com';
  const testPassword = '123456';

  Future<void> _ensureLoggedIn(WidgetTester tester) async {
    // Splash + lo que haga main al inicio
    await tester.pumpAndSettle(const Duration(seconds: 8));

    final emailField = find.byKey(const Key('txtEmailLogin'));

    // Si hay pantalla de login, logueamos
    if (tester.any(emailField)) {
      final passwordField = find.byKey(const Key('txtPasswordLogin'));
      final loginButton = find.byKey(const Key('btnLogin'));

      expect(passwordField, findsOneWidget);
      expect(loginButton, findsOneWidget);

      await tester.enterText(emailField, testEmail);
      await tester.enterText(passwordField, testPassword);
      await tester.pumpAndSettle();

      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 8));
    }

    // Al final deberíamos estar en el dashboard
    expect(find.byKey(const Key('dashboardPage')), findsOneWidget);
  }

  testWidgets(
    'HU-M2: El usuario realiza una donación monetaria a una campaña',
    (WidgetTester tester) async {
      // 1) Lanzar app
      app.main();

      // 2) Asegurarnos que estamos logueados y en el Dashboard
      await _ensureLoggedIn(tester);

      // 3) Esperar a que carguen las campañas destacadas
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // 4) Tocar la primera campaña destacada
      final campaniaCardFinder = find.byKey(const Key('campaniaCard'));
      expect(campaniaCardFinder, findsWidgets); // debe haber al menos una

      await tester.tap(campaniaCardFinder.first);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 5) En DetalleCampaniaPage, tocar "Donar Ahora"
      final btnDonarAhora = find.byKey(const Key('btnDonarAhora'));
      expect(btnDonarAhora, findsOneWidget);

      await tester.tap(btnDonarAhora);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 6) En DonacionPage (monetaria por defecto), llenar monto
      final montoField = find.byKey(const Key('txtMontoDonacion'));
      expect(montoField, findsOneWidget);

      await tester.enterText(montoField, '150');
      await tester.pumpAndSettle();

      // 7) Hacer scroll manual para mostrar el botón "Continuar"
      final scrollDonacion = find.byKey(const Key('scrollDonacion'));
      expect(scrollDonacion, findsOneWidget);

      await tester.drag(scrollDonacion, const Offset(0, -400));
      await tester.pumpAndSettle();

      if (!tester.any(find.byKey(const Key('btnContinuarDonacion')))) {
        await tester.drag(scrollDonacion, const Offset(0, -400));
        await tester.pumpAndSettle();
      }

      final btnContinuar = find.byKey(const Key('btnContinuarDonacion'));
      expect(btnContinuar, findsOneWidget);

      await tester.tap(btnContinuar);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 8) En ConfirmarDonacionPage, confirmar
      final btnConfirmar = find.byKey(const Key('btnConfirmarDonacion'));
      expect(btnConfirmar, findsOneWidget);

      await tester.tap(btnConfirmar);
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // 9) Ahora debería aparecer el FeedbackDialog -> pulsamos "Cancelar"
      final btnCancelarFeedback = find.byKey(const Key('btnCancelarFeedback'));
      expect(btnCancelarFeedback, findsOneWidget);

      await tester.tap(btnCancelarFeedback);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 10) Después de cerrar el feedback, debe navegar al Dashboard
      expect(find.byKey(const Key('dashboardPage')), findsOneWidget);
    },
  );
}