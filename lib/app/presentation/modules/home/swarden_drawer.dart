import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swardenapp/app/core/extensions/swarden_exceptions_extensions.dart';
import 'package:swardenapp/app/core/generated/translations.g.dart';
import 'package:swardenapp/app/core/utils/either/either.dart';
import 'package:swardenapp/app/presentation/controllers/language_controller.dart';
import 'package:swardenapp/app/presentation/controllers/session_controller.dart';
import 'package:swardenapp/app/presentation/global/dialogs/dialogs.dart';
import 'package:swardenapp/app/presentation/global/dialogs/language_dialog.dart';
import 'package:swardenapp/app/presentation/global/dialogs/password_generator_dialog.dart';

class SwardenDrawer extends ConsumerWidget {
  const SwardenDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Swarden',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'User: ${ref.watch(sessionControllerProvider)?.email ?? ''}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            onTap: () async {
              final selectedLocale = await showLanguageDialog(context);
              if (selectedLocale != null) {
                ref
                    .read(languageControllerProvider.notifier)
                    .changeLocale(selectedLocale);
              }
            },
            title: Text(texts.profile.changeLanguage),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            onTap: () async {
              await showPasswordGeneratorDialog(context, copyPswdOption: true);
            },
            title: Text(texts.entries.passwordGenerator),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            onTap: () async {
              try {
                final confirm = SwardenDialogs.dialog(
                  context: context,
                  title: texts.auth.logout,
                  content: Text(texts.entries.logoutConfirmation),
                );
                if (!await confirm) return;
                await ref.read(sessionControllerProvider.notifier).signOut();
              } catch (e) {
                if (context.mounted) {
                  SwardenDialogs.snackBar(
                    context,
                    texts.auth.anErrorHasOccurred,
                    isError: true,
                  );
                }
              }
            },
            title: Text(texts.auth.logout),
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            onTap: () async {
              final confirm = await SwardenDialogs.dialog(
                context: context,
                title: texts.auth.deleteAccount,
                content: Text(texts.entries.deleteAccountConfirmation),
              );
              if (!confirm) return;
              if (!context.mounted) return;
              final password = await SwardenDialogs.textFieldDialog(
                context: context,
                text: texts
                    .profile
                    .enterYourPasswordToVerifyTheDeletionOfYourAccount,
                hintText: texts.auth.passwordHint,
              );
              if (password == null || password.isEmpty) return;
              try {
                final result = await ref
                    .read(sessionControllerProvider.notifier)
                    .deleteAccount(password);

                result.when(
                  left: (error) {
                    SwardenDialogs.snackBar(
                      context,
                      error.toText(),
                      isError: true,
                    );
                  },
                  right: (success) {},
                );
              } catch (e) {
                if (context.mounted) {
                  SwardenDialogs.snackBar(
                    context,
                    texts.auth.anErrorHasOccurred,
                    isError: true,
                  );
                }
              }
            },
            title: Text(texts.auth.deleteAccount),
          ),
        ],
      ),
    );
  }
}
