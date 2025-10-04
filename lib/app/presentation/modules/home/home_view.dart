import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swardenapp/app/core/constants/global.dart';
import 'package:swardenapp/app/core/extensions/num_to_sizedbox_extensions.dart';
import 'package:swardenapp/app/core/generated/translations.g.dart';
import 'package:swardenapp/app/presentation/controllers/session_controller.dart';
import 'package:swardenapp/app/presentation/global/dialogs.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Global.appName),
        actions: [
          PopupMenuButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                onTap: () async {
                  final confirm = SwardenDialogs.dialog(
                    context: context,
                    title: texts.auth.logout,
                    content: Text('Vols tancar sessió?'),
                  );
                  if (!await confirm) return;
                  await ref.read(sessionControllerProvider.notifier).signOut();
                },
                child: Row(
                  children: [
                    const Icon(Icons.logout),
                    10.w,
                    Text(texts.auth.logout),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () async {
                  final confirm = await SwardenDialogs.dialog(
                    context: context,
                    title: texts.auth.deleteAccount,
                    content: Text(
                      'Vols eliminar el teu compte? Aquesta acció és irreversible.  ',
                    ),
                  );
                  if (!confirm) return;
                  ref.read(sessionControllerProvider.notifier).deleteAccount();
                },
                child: Row(
                  children: [
                    const Icon(Icons.delete),
                    10.w,
                    Text(texts.auth.deleteAccount),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: const Center(child: Text('Benvingut a la pàgina d\'inici!')),
    );
  }
}
