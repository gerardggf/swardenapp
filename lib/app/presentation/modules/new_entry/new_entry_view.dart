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
import 'package:swardenapp/app/domain/use_cases/entries/create_entry_use_case.dart';
import 'package:swardenapp/app/presentation/controllers/session_controller.dart';
import 'package:swardenapp/app/presentation/global/dialogs/dialogs.dart';
import 'package:swardenapp/app/presentation/global/dialogs/password_generator_dialog.dart';
import 'package:swardenapp/app/presentation/global/functions/validators.dart';
import 'package:swardenapp/app/presentation/global/widgets/back_button.dart';
import 'package:swardenapp/app/presentation/modules/home/home_view.dart';

/// Vista per crear una nova entrada
class NewEntryView extends ConsumerStatefulWidget {
  static const String routeName = 'new-entry';

  const NewEntryView({super.key});

  @override
  ConsumerState<NewEntryView> createState() => _NewEntryViewState();
}

class _NewEntryViewState extends ConsumerState<NewEntryView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(sessionControllerProvider);
      if (user == null) {
        throw Exception(texts.entries.userNotFound);
      }

      final createEntryUseCase = ref.read(createEntryUseCaseProvider);

      final result = await createEntryUseCase.call(
        CreateEntryParams(
          userId: user.uid,
          entry: EntryDataModel(
            title: _titleController.text.trim(),
            username: _usernameController.text.trim(),
            password: _passwordController.text,
            createdAt: DateTime.now(),
          ),
        ),
      );

      if (!mounted) return;

      result.when(
        left: (error) {
          SwardenDialogs.snackBar(
            context,
            '${texts.entries.errorCreatingEntry}: ${error.toString()}',
            isError: true,
          );
        },
        right: (success) {
          if (success) {
            SwardenDialogs.snackBar(
              context,
              texts.entries.entryCreatedSuccessfully,
            );
            ref.invalidate(entriesFutureProvider);
            context.pop();
          } else {
            SwardenDialogs.snackBar(
              context,
              texts.entries.errorCreatingEntry,
              isError: true,
            );
          }
        },
      );
    } catch (e) {
      SwardenDialogs.snackBar(
        context,
        '${texts.entries.errorCreatingEntry}: ${e.toString()}',
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
                            texts.entries.newEntry,
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
                                  Icons.info_outline,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              12.w,
                              Text(
                                texts.entries.generalInfo,
                                style: context.themeTM?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          20.h,
                          TextFormField(
                            key: const ValueKey('entry_title_field'),
                            onTapOutside: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: texts.entries.entryTitle,
                              hintText: texts.entries.entryTitleHint,
                              prefixIcon: const Icon(Icons.label_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return texts.entries.titleRequiredLabel;
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    24.h,

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
                                  color: Colors.green.withAlpha(24),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.security,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ),
                              12.w,
                              Text(
                                texts.entries.accessCredentials,
                                style: context.themeTM?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                          20.h,
                          TextFormField(
                            key: const ValueKey('entry_username_field'),
                            onTapOutside: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: texts.entries.usernameOrEmail,
                              hintText: texts.entries.usernameOrEmailHint,
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.green,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return texts.entries.usernameRequired;
                              }
                              return null;
                            },
                          ),
                          16.h,
                          TextFormField(
                            key: const ValueKey('entry_password_field'),
                            onTapOutside: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: texts.entries.passwordLabel,
                              hintText: texts.entries.passwordSecureHint,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.vpn_key),
                                    tooltip: texts.entries.passwordGenerator,
                                    onPressed: () async {
                                      final password =
                                          await showPasswordGeneratorDialog(
                                            context,
                                          );
                                      if (password != null) {
                                        _passwordController.text = password;
                                      }
                                    },
                                  ),
                                  IconButton(
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
                                ],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.green,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (value) =>
                                Validators.validatePassword(value),
                          ),
                        ],
                      ),
                    ),

                    32.h,

                    SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        key: const ValueKey('save_entry_button'),
                        onPressed: _isLoading ? null : _saveEntry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _isLoading
                              ? texts.entries.savingEntry
                              : texts.entries.saveEntry,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    24.h,

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            color: Colors.blue.shade600,
                            size: 20,
                          ),
                          12.w,
                          Expanded(
                            child: Text(
                              texts.entries.zeroKnowledgeInfo,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    32.h,
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
