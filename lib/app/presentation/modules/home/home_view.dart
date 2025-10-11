import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swardenapp/app/core/constants/assets.dart';
import 'package:swardenapp/app/core/constants/colors.dart';
import 'package:swardenapp/app/core/constants/global.dart';
import 'package:swardenapp/app/core/extensions/num_to_sizedbox_extensions.dart';
import 'package:swardenapp/app/core/generated/translations.g.dart';
import 'package:swardenapp/app/core/utils/either/either.dart';
import 'package:swardenapp/app/domain/models/entry_model.dart';
import 'package:swardenapp/app/domain/use_cases/use_case_providers.dart';
import 'package:swardenapp/app/domain/use_cases/entries/get_user_entries_use_case.dart';
import 'package:swardenapp/app/domain/use_cases/entries/delete_entry_use_case.dart';
import 'package:swardenapp/app/presentation/controllers/session_controller.dart';
import 'package:swardenapp/app/presentation/global/dialogs.dart';
import 'package:swardenapp/app/presentation/global/widgets/error_info_widget.dart';
import 'package:swardenapp/app/presentation/global/widgets/loading_widget.dart';
import 'package:swardenapp/app/presentation/modules/edit_entry/edit_entry_view.dart';
import 'package:swardenapp/app/presentation/modules/entry/entry_view.dart';
import 'package:swardenapp/app/presentation/modules/home/widgets/entry_tile_widget.dart';
import 'package:swardenapp/app/presentation/modules/new_entry/new_entry_view.dart';

final entriesFutureProvider = FutureProvider<List<EntryDataModel>>((ref) async {
  final userId = ref.watch(sessionControllerProvider)?.uid;
  if (userId == null) {
    return [];
  }

  final getUserEntriesUseCase = ref.read(getUserEntriesUseCaseProvider);
  final result = await getUserEntriesUseCase(
    GetUserEntriesParams(userId: userId),
  );

  return result.when(left: (_) => [], right: (r) => r);
});

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesFuture = ref.watch(entriesFutureProvider);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(Assets.icon, width: 30, height: 30),
            8.w,
            const Text(Global.appName),
          ],
        ),
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
                  try {
                    final confirm = SwardenDialogs.dialog(
                      context: context,
                      title: texts.auth.logout,
                      content: Text('Vols tancar sessió?'),
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
      body: Stack(
        children: [
          Image.asset(
            Assets.bg,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            color: Colors.white.withAlpha(230),
            width: double.infinity,
            height: double.infinity,
          ),
          RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: Colors.white,
            onRefresh: () => ref.refresh(entriesFutureProvider.future),
            child: entriesFuture.when(
              data: (entries) {
                return ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          5.w,
                          Text(
                            texts.global.swipeToRefresh,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...List.generate(entries.length, (index) {
                      final entry = entries[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == entries.length - 1 ? 0 : 10,
                        ),
                        child: EntryTileWidget(
                          entry: entry,
                          onTap: () {
                            context.pushNamed(
                              EntryView.routeName,
                              extra: entry,
                            );
                          },
                          onEdit: () {
                            context.pushNamed(
                              EditEntryView.routeName,
                              extra: entry,
                            );
                          },
                          onDelete: () async {
                            final deleteEntryUseCase = ref.read(
                              deleteEntryUseCaseProvider,
                            );
                            final result = await deleteEntryUseCase(
                              DeleteEntryParams(
                                userId: ref
                                    .read(sessionControllerProvider)!
                                    .uid,
                                entryId: entry.id!,
                              ),
                            );
                            if (!context.mounted) return;

                            result.when(
                              left: (error) {
                                SwardenDialogs.snackBar(
                                  context,
                                  'Error eliminant la entrada',
                                  isError: true,
                                );
                              },
                              right: (success) {
                                if (success) {
                                  SwardenDialogs.snackBar(
                                    context,
                                    'La entrada s\'ha eliminat correctament',
                                  );
                                  ref.invalidate(entriesFutureProvider);
                                } else {
                                  SwardenDialogs.snackBar(
                                    context,
                                    'Error eliminant la entrada',
                                    isError: true,
                                  );
                                }
                              },
                            );
                          },
                        ),
                      );
                    }),
                  ],
                );
              },
              error: (e, _) => ErrorInfoWidget(text: e.toString()),
              loading: () => LoadingWidget(),
            ),
          ),
        ],
      ),
    );
  }
}
