import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:donaciones_movil/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const testEmail = 'eliasandres2504@gmail.com';
  const testPassword = '123456';

  Future<void> _ensureLoggedIn(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 8));

    final emailField = find.byKey(const Key('txtEmailLogin'));

    if (tester.any(emailField)) {
      final passwordField = find.byKey(const Key('txtPasswordLogin'));
      final loginButton = find.byKey(const Key('btnLogin'));

      await tester.enterText(emailField, testEmail);
      await tester.enterText(passwordField, testPassword);
      await tester.pumpAndSettle();

      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 8));
    }

    expect(find.byKey(const Key('dashboardPage')), findsOneWidget);
  }

  testWidgets(
    'HU-M3: El usuario publica un comentario desde el feedback dialog',
    (WidgetTester tester) async {
      app.main();
      await _ensureLoggedIn(tester);

      await tester.pumpAndSettle(const Duration(seconds: 8));

      final campania = find.byKey(const Key('campaniaCard'));
      expect(campania, findsWidgets);

      await tester.tap(campania.first);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final donarBtn = find.byKey(const Key('btnDonarAhora'));
      await tester.tap(donarBtn);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final montoField = find.byKey(const Key('txtMontoDonacion'));
      expect(montoField, findsOneWidget);

      await tester.enterText(montoField, '150');
      await tester.pumpAndSettle();

      final scroll = find.byKey(const Key('scrollDonacion'));
      await tester.drag(scroll, const Offset(0, -500));
      await tester.pumpAndSettle();

      final continuarBtn = find.byKey(const Key('btnContinuarDonacion'));
      expect(continuarBtn, findsOneWidget);

      await tester.tap(continuarBtn);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final btnConfirmar = find.byKey(const Key('btnConfirmarDonacion'));
      await tester.tap(btnConfirmar);
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // --- AQUÍ INICIA EL FEEDBACK ---
      // 1) Seleccionar calificación
      final star4 = find.byKey(const Key('star4'));
      expect(star4, findsOneWidget);

      await tester.tap(star4);
      await tester.pumpAndSettle();

      // 2) Escribir comentario
      final comentarioField = find.byKey(const Key('txtComentarioFeedback'));
      expect(comentarioField, findsOneWidget);

      await tester.enterText(comentarioField, 'Muy buena campaña, excelente organización.');
      await tester.pumpAndSettle();

      // 3) Enviar feedback
      final btnEnviar = find.byKey(const Key('btnEnviarFeedback'));
      expect(btnEnviar, findsOneWidget);

      await tester.tap(btnEnviar);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Esperar la animación de ¡Gracias!
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 4) Debe volver al dashboard
      expect(find.byKey(const Key('dashboardPage')), findsOneWidget);
    },
  );
}