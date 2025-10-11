import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swardenapp/app/core/constants/colors.dart';
import 'package:swardenapp/app/core/extensions/num_to_sizedbox_extensions.dart';
import 'package:swardenapp/app/core/extensions/text_theme_extension.dart';
import 'package:swardenapp/app/core/generated/translations.g.dart';
import 'package:swardenapp/app/domain/models/entry_model.dart';
import 'package:swardenapp/app/core/utils/either/either.dart';
import 'package:swardenapp/app/domain/use_cases/use_case_providers.dart';
import 'package:swardenapp/app/domain/use_cases/entries/delete_entry_use_case.dart';
import 'package:swardenapp/app/presentation/controllers/session_controller.dart';
import 'package:swardenapp/app/presentation/global/dialogs.dart';
import 'package:swardenapp/app/presentation/global/widgets/warning_widget.dart';
import 'package:swardenapp/app/presentation/modules/edit_entry/edit_entry_view.dart';
import 'package:swardenapp/app/presentation/modules/entry/widgets/info_card_widget.dart';
import 'package:swardenapp/app/presentation/modules/home/home_view.dart';

class EntryView extends ConsumerStatefulWidget {
  static const String routeName = 'entry';

  final EntryDataModel entry;

  const EntryView({super.key, required this.entry});

  @override
  ConsumerState<EntryView> createState() => _EntryViewState();
}

class _EntryViewState extends ConsumerState<EntryView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary.withAlpha(24), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withAlpha(230),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    16.w,
                    Expanded(
                      child: Text(
                        widget.entry.title,
                        style: context.themeHS?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    // Comprovem que la informació desxifrada té associat el seu ID per poder editar-la
                    if (widget.entry.id != null)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          context.pushReplacementNamed(
                            EditEntryView.routeName,
                            extra: widget.entry,
                          );
                        },
                        tooltip: 'Editar',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withAlpha(230),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    10.w,
                    // Comprovem que la informació desxifrada té associat el seu ID per poder eliminar-la
                    if (widget.entry.id != null)
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirm = await SwardenDialogs.dialog(
                            context: context,
                            title: 'Eliminar Entrada',
                            content: Text(
                              'Estàs segur que vols eliminar aquesta entrada? Aquesta acció no es pot desfer.',
                            ),
                          );
                          if (!confirm) return;

                          final deleteEntryUseCase = ref.read(
                            deleteEntryUseCaseProvider,
                          );
                          final result = await deleteEntryUseCase(
                            DeleteEntryParams(
                              userId: ref.watch(sessionControllerProvider)!.uid,
                              entryId: widget.entry.id!,
                            ),
                          );

                          if (!context.mounted) return;

                          result.when(
                            left: (error) {
                              SwardenDialogs.snackBar(
                                context,
                                'Error eliminant la entrada: ${error.toString()}',
                                isError: true,
                              );
                            },
                            right: (success) {
                              if (success) {
                                SwardenDialogs.snackBar(
                                  context,
                                  'La entrada s\'ha eliminat correctament',
                                );
                                context.pop();
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
                        tooltip: 'Eliminar',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withAlpha(230),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                  ],
                ),
              ),

              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        InfoCardWidget(
          title: 'Títol',
          value: widget.entry.title,
          icon: Icons.label_outlined,
        ),

        InfoCardWidget(
          title: 'Nom d\'usuari',
          value: widget.entry.username,
          icon: Icons.person_outlined,
          iconColor: Colors.green,
        ),

        InfoCardWidget(
          title: 'Contrasenya',
          value: widget.entry.password,
          icon: Icons.lock_outlined,
          iconColor: Colors.red,
          isPassword: true,
        ),

        10.h,
        WarningWidget(
          bgColor: Colors.green.shade50,
          content:
              'Aquesta informació està desxifrada només en memòria i no es guarda mai en text pla.',
          icon: Icons.shield_outlined,
          color: const Color.fromARGB(255, 48, 136, 51),
        ),

        40.h,
      ],
    );
  }
}
