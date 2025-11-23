import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swardenapp/app/core/constants/assets.dart';
import 'package:swardenapp/app/core/constants/colors.dart';
import 'package:swardenapp/app/core/constants/global.dart';
import 'package:swardenapp/app/core/extensions/num_to_sizedbox_extensions.dart';
import 'package:swardenapp/app/core/extensions/swarden_exceptions_extensions.dart';
import 'package:swardenapp/app/core/generated/translations.g.dart';
import 'package:swardenapp/app/core/global_providers.dart';
import 'package:swardenapp/app/core/utils/either/either.dart';
import 'package:swardenapp/app/presentation/controllers/language_controller.dart';
import 'package:swardenapp/app/presentation/controllers/session_controller.dart';
import 'package:swardenapp/app/presentation/global/dialogs/dialogs.dart';
import 'package:swardenapp/app/presentation/global/dialogs/language_dialog.dart';
import 'package:swardenapp/app/presentation/global/dialogs/password_generator_dialog.dart';

/// Barra lateral personalitzada de l'aplicació Swarden
class SwardenDrawer extends ConsumerWidget {
  const SwardenDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: AppColors.primary),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(80),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(Assets.icon, height: 40, width: 40),
                      ),
                      10.w,
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              Global.appName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ref.watch(sessionControllerProvider)?.email ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
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
                      if (!context.mounted) return;
                      context.pop();
                    }
                  },
                  title: Text(texts.profile.changeLanguage),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  onTap: () async {
                    await showPasswordGeneratorDialog(
                      context,
                      copyPswdOption: true,
                    );
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
                      await ref
                          .read(sessionControllerProvider.notifier)
                          .signOut();
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
          ),
          if (ref.watch(packageInfoProvider).value != null)
            Text(
              'v${ref.watch(packageInfoProvider).value!.version}+${ref.watch(packageInfoProvider).value!.buildNumber}',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          10.h,
        ],
      ),
    );
  }
}
