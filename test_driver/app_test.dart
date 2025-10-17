import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Test d\'integració complet amb Flutter Driver', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

    test(
      'L\'usuari inicia sessió, desbloqueja la bóveda i crea una entrada',
      () async {
        await Future.delayed(const Duration(seconds: 4));

        await driver.waitFor(find.byValueKey('email_field'));
        await driver.tap(find.byValueKey('email_field'));
        await driver.enterText('gerardggf@uoc.edu');
        await Future.delayed(const Duration(milliseconds: 500));

        await driver.tap(find.byValueKey('password_field'));
        await driver.enterText('123456');
        await Future.delayed(const Duration(milliseconds: 500));

        await driver.tap(find.byValueKey('sign_in_button'));

        await Future.delayed(const Duration(seconds: 5));

        await driver.waitFor(find.byValueKey('vault_password_field'));
        await driver.tap(find.byValueKey('vault_password_field'));
        await driver.enterText('123456');
        await Future.delayed(const Duration(milliseconds: 500));

        await driver.tap(find.byValueKey('unlock_button'));

        await Future.delayed(const Duration(seconds: 3));

        await driver.waitFor(find.byValueKey('add_entry_button'));
        await driver.tap(find.byValueKey('add_entry_button'));

        await Future.delayed(const Duration(seconds: 2));

        await driver.waitFor(find.byValueKey('entry_title_field'));
        await driver.tap(find.byValueKey('entry_title_field'));
        await driver.enterText('Entrada de prova');
        await Future.delayed(const Duration(milliseconds: 300));

        await driver.tap(find.byValueKey('entry_username_field'));
        await driver.enterText('gerardggf@example.com');
        await Future.delayed(const Duration(milliseconds: 300));

        await driver.tap(find.byValueKey('entry_password_field'));
        await driver.enterText('TestPassword1234');
        await Future.delayed(const Duration(milliseconds: 300));

        await driver.tap(find.byValueKey('save_entry_button'));

        await Future.delayed(const Duration(seconds: 3));

        await driver.waitFor(find.text('Entrada de prova'));
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );
  });
}
