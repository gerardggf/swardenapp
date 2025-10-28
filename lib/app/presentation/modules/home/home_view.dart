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
import 'package:swardenapp/app/presentation/controllers/language_controller.dart';
import 'package:swardenapp/app/presentation/controllers/session_controller.dart';
import 'package:swardenapp/app/presentation/global/dialogs/dialogs.dart';
import 'package:swardenapp/app/presentation/global/widgets/error_info_widget.dart';
import 'package:swardenapp/app/presentation/global/widgets/loading_widget.dart';
import 'package:swardenapp/app/presentation/modules/edit_entry/edit_entry_view.dart';
import 'package:swardenapp/app/presentation/modules/entry/entry_view.dart';
import 'package:swardenapp/app/presentation/modules/home/swarden_drawer.dart';
import 'package:swardenapp/app/presentation/modules/home/widgets/entry_tile_widget.dart';
import 'package:swardenapp/app/presentation/modules/new_entry/new_entry_view.dart';

final entriesFutureProvider = FutureProvider<List<EntryDataModel>>((ref) async {
  final userId = ref.watch(sessionControllerProvider)?.uid;
  if (userId == null) {
    return [];
  }

  final getUserEntriesUseCase = ref.read(getUserEntriesUseCaseProvider);
  final result = await getUserEntriesUseCase.call(
    GetUserEntriesParams(userId: userId),
  );

  return result.when(left: (_) => [], right: (r) => r);
});

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  static const routeName = '/home';

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EntryDataModel> _filterEntries(List<EntryDataModel> entries) {
    if (_searchQuery.isEmpty) return entries;

    return entries.where((entry) {
      final titleMatch = entry.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final usernameMatch = entry.username.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return titleMatch || usernameMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Observar els canvis d'idioma per reconstruir la vista
    ref.watch(languageControllerProvider);

    final entriesFuture = ref.watch(entriesFutureProvider);
    return Scaffold(
      drawer: SwardenDrawer(),
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
            key: const ValueKey('add_entry_button'),
            onPressed: () {
              context.pushNamed(NewEntryView.routeName);
            },
            icon: const Icon(Icons.add, size: 30),
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
                final filteredEntries = _filterEntries(entries);

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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: texts.entries.searchEntries,
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.primary,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    if (filteredEntries.isEmpty && _searchQuery.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            16.h,
                            Text(
                              texts.entries.noEntriesFound,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ...List.generate(filteredEntries.length, (index) {
                      final entry = filteredEntries[index];
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
                            final result = await deleteEntryUseCase.call(
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
                                  texts.entries.errorDeletingEntry,
                                  isError: true,
                                );
                              },
                              right: (success) {
                                if (success) {
                                  SwardenDialogs.snackBar(
                                    context,
                                    texts.entries.entryDeletedSuccessfully,
                                  );
                                  ref.invalidate(entriesFutureProvider);
                                } else {
                                  SwardenDialogs.snackBar(
                                    context,
                                    texts.entries.errorDeletingEntry,
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
