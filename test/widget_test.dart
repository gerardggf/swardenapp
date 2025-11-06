import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:swardenapp/app/core/generated/translations.g.dart';
import 'package:swardenapp/app/presentation/global/dialogs/password_generator_dialog.dart';

void main() {
  setUpAll(() => LocaleSettings.setLocaleRaw('ca'));

  Widget createApp(Widget child) {
    return TranslationProvider(
      child: MaterialApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => Scaffold(body: child),
            ),
          ],
        ),
      ),
    );
  }

  testWidgets('password generator adapts to selected parameters', (
    tester,
  ) async {
    await tester.pumpWidget(
      createApp(
        /// Crea una aplicació de prova amb el diàleg incrustat
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showPasswordGeneratorDialog(context),
            child: const Text('Obrir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Obrir'));
    await tester.pumpAndSettle();

    // Test 1: Només números
    await tester.tap(
      find.byType(CheckboxListTile).at(0),
    ); // Deshabilitar majúscules
    await tester.tap(
      find.byType(CheckboxListTile).at(1),
    ); // Deshabilitar minúscules
    await tester.tap(
      find.byType(CheckboxListTile).at(3),
    ); // Deshabilitar símbols
    await tester.pumpAndSettle();

    final passwordWidget = tester.widget<SelectableText>(
      find.byType(SelectableText),
    );
    final password = passwordWidget.data!;

    expect(
      RegExp(r'^[0-9]+$').hasMatch(password),
      isTrue,
      reason: 'Hauria de contenir números: $password',
    );

    // Test 2: Canviar longitud
    expect(password.length, 16); // Longitud per defecte

    await tester.drag(find.byType(Slider), const Offset(50, 0));
    await tester.pumpAndSettle();

    final newPasswordWidget = tester.widget<SelectableText>(
      find.byType(SelectableText),
    );
    final newPassword = newPasswordWidget.data!;

    expect(
      newPassword.length,
      isNot(16),
      reason: 'La longitut hauria de canviar',
    );
    expect(
      RegExp(r'^[0-9]+$').hasMatch(newPassword),
      isTrue,
      reason: 'Hauria de contenir només números: $newPassword',
    );
  });
}
