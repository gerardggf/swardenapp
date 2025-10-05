import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swardenapp/app/core/constants/global.dart';
import 'package:swardenapp/app/core/extensions/num_to_sizedbox_extensions.dart';
import 'package:swardenapp/app/core/generated/translations.g.dart';
import 'package:swardenapp/app/domain/either/either.dart';
import 'package:swardenapp/app/domain/models/entry_model.dart';
import 'package:swardenapp/app/domain/repos/entries_repo.dart';
import 'package:swardenapp/app/presentation/controllers/session_controller.dart';
import 'package:swardenapp/app/presentation/global/dialogs.dart';
import 'package:swardenapp/app/presentation/global/widgets/error_info_widget.dart';
import 'package:swardenapp/app/presentation/global/widgets/loading_widget.dart';
import 'package:swardenapp/app/presentation/modules/edit_entry/edit_entry_view.dart';
import 'package:swardenapp/app/presentation/modules/entry/entry_view.dart';
import 'package:swardenapp/app/presentation/modules/home/widgets/entry_tile_widget.dart';
import 'package:swardenapp/app/presentation/modules/new_entry/new_entry_view.dart';

final entriesFutureProvider = FutureProvider<List<EntryDataModel>>((ref) async {
  final sessionController = ref.read(sessionControllerProvider);
  if (sessionController == null) {
    return [];
  }
  return ref.read(entriesRepoProvider).getEntries(sessionController.uid).then((
    value,
  ) {
    return value.when(left: (_) => [], right: (r) => r);
  });
});

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesFuture = ref.watch(entriesFutureProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(Global.appName),
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed(NewEntryView.routeName);
            },
            icon: const Icon(Icons.add, size: 30),
          ),
          PopupMenuButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.black),
                    10.w,
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        ref.watch(sessionControllerProvider)?.email ?? '',
                      ),
                    ),
                  ],
                ),
              ),
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
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(entriesFutureProvider.future),
        child: entriesFuture.when(
          data: (entries) {
            return ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return EntryTileWidget(
                  entry: entry,
                  onTap: () {
                    context.pushNamed(EntryView.routeName, extra: entry);
                  },
                  onEdit: () {
                    context.pushNamed(EditEntryView.routeName, extra: entry);
                  },
                  onDelete: () async {
                    final result = await ref
                        .read(entriesRepoProvider)
                        .deleteEntry(
                          ref.read(sessionControllerProvider)!.uid,
                          entry.id!,
                        );
                    if (!context.mounted) return;
                    if (result) {
                      SwardenDialogs.snackBar(
                        context,
                        'La entrada s\'ha eliminat correctament',
                      );
                      ref.invalidate(entriesFutureProvider);
                    } else {
                      SwardenDialogs.snackBar(
                        context,
                        texts.auth.anErrorHasOccurred,
                        isError: true,
                      );
                    }
                  },
                );
              },
            );
          },
          error: (e, _) => ErrorInfoWidget(text: e.toString()),
          loading: () => LoadingWidget(),
        ),
      ),
    );
  }
}
