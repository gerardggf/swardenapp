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
import 'package:swardenapp/app/domain/use_cases/entries/update_entry_use_case.dart';
import 'package:swardenapp/app/presentation/controllers/session_controller.dart';
import 'package:swardenapp/app/presentation/global/dialogs.dart';
import 'package:swardenapp/app/presentation/global/functions/validators.dart';
import 'package:swardenapp/app/presentation/global/widgets/back_button.dart';
import 'package:swardenapp/app/presentation/modules/home/home_view.dart';

class EditEntryView extends ConsumerStatefulWidget {
  static const String routeName = 'edit-entry';

  final EntryDataModel entryData;

  const EditEntryView({super.key, required this.entryData});

  @override
  ConsumerState<EditEntryView> createState() => _EditEntryViewState();
}

class _EditEntryViewState extends ConsumerState<EditEntryView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Inicialitzar els controladors amb les dades de l'entrada
    _titleController = TextEditingController(text: widget.entryData.title);
    _usernameController = TextEditingController(
      text: widget.entryData.username,
    );
    _passwordController = TextEditingController(
      text: widget.entryData.password,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(sessionControllerProvider);
      if (user == null) {
        throw Exception(texts.entries.userNotFound);
      }

      final updateEntryUseCase = ref.read(updateEntryUseCaseProvider);

      // Crear l'entrada actualitzada mantenint l'ID i data de creació originals
      final updatedEntry = EntryDataModel(
        title: _titleController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        createdAt: widget.entryData.createdAt,
      );

      final result = await updateEntryUseCase(
        UpdateEntryParams(
          userId: user.uid,
          entryId: widget.entryData.id!,
          entry: updatedEntry,
        ),
      );

      if (!mounted) return;

      result.when(
        left: (error) {
          SwardenDialogs.snackBar(
            context,
            '${texts.entries.errorUpdatingEntry}: ${error.toString()}',
            isError: true,
          );
        },
        right: (success) {
          if (success) {
            SwardenDialogs.snackBar(
              context,
              texts.entries.entryUpdatedSuccessfully,
            );
            ref.invalidate(entriesFutureProvider);
            context.pop();
          } else {
            SwardenDialogs.snackBar(
              context,
              texts.entries.errorUpdatingEntry,
              isError: true,
            );
          }
        },
      );
    } catch (e) {
      SwardenDialogs.snackBar(
        context,
        '${texts.entries.errorUpdatingEntry}: ${e.toString()}',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        SwardenBackButton(),
                        16.w,
                        Expanded(
                          child: Text(
                            texts.entries.editEntry,
                            style: context.themeHM?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (_isLoading) CircularProgressIndicator(),
                      ],
                    ),

                    32.h,

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(24),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.edit_outlined,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              12.w,
                              Text(
                                texts.entries.entryInfo,
                                style: context.themeTM?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),

                          24.h,

                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: texts.entries.titleRequired,
                              hintText: texts.entries.titleHint,
                              prefixIcon: Icon(Icons.title_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: Validators.validateIsNotEmpty,
                            textInputAction: TextInputAction.next,
                          ),

                          20.h,

                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: texts.entries.usernameEmailRequired,
                              hintText: texts.entries.usernameHint,
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: Validators.validateIsNotEmpty,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          20.h,

                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: texts.entries.passwordRequired,
                              hintText: texts.entries.passwordHint,
                              prefixIcon: Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: Validators.validatePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _updateEntry(),
                          ),
                        ],
                      ),
                    ),

                    32.h,

                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withAlpha(204),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(50),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateEntry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.save_outlined,
                                    color: Colors.white,
                                  ),
                                  8.w,
                                  Text(
                                    texts.entries.updateEntry,
                                    style: context.themeTM?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    24.h,

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withAlpha(50),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          12.w,
                          Expanded(
                            child: Text(
                              texts.entries.requiredFieldsInfo,
                              style: context.themeBS?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
