import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swardenapp/app/core/constants/colors.dart';
import 'package:swardenapp/app/core/extensions/num_to_sizedbox_extensions.dart';
import 'package:swardenapp/app/core/extensions/text_theme_extension.dart';
import 'package:swardenapp/app/domain/models/entry_model.dart';
import 'package:swardenapp/app/domain/repos/entries_repo.dart';
import 'package:swardenapp/app/presentation/controllers/session_controller.dart';
import 'package:swardenapp/app/presentation/global/dialogs.dart';
import 'package:swardenapp/app/presentation/global/functions/validators.dart';
import 'package:swardenapp/app/presentation/global/widgets/back_button.dart';
import 'package:swardenapp/app/presentation/modules/home/home_view.dart';

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
        throw Exception('Usuari no trobat');
      }

      final entriesRepo = ref.read(entriesRepoProvider);

      final result = await entriesRepo.addEntry(
        user.uid,
        EntryDataModel(
          title: _titleController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          createdAt: DateTime.now(),
        ),
      );
      if (!mounted) return;
      if (result) {
        SwardenDialogs.snackBar(context, 'Entrada creada correctament!');
        ref.invalidate(entriesFutureProvider);
        context.pop();
      } else {
        SwardenDialogs.snackBar(context, 'Error creant entrada', isError: true);
      }
    } catch (e) {
      SwardenDialogs.snackBar(
        context,
        'Error creant entrada: ${e.toString()}',
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
                    // Header
                    Row(
                      children: [
                        SwardenBackButton(),
                        16.w,
                        Expanded(
                          child: Text(
                            'Nova Entrada',
                            style: context.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (_isLoading) CircularProgressIndicator(),
                      ],
                    ),

                    32.h,

                    // Títol de la secció
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
                                'Informació General',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          20.h,
                          TextFormField(
                            onTapOutside: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Títol de l\'entrada',
                              hintText: 'Ex: GitHub, Gmail, Facebook...',
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
                                return 'El títol és obligatori';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    24.h,

                    // Credencials
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
                                'Credencials d\'Accés',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                          20.h,
                          TextFormField(
                            onTapOutside: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Nom d\'usuari o email',
                              hintText: 'email@example.com',
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
                                return 'El nom d\'usuari és obligatori';
                              }
                              return null;
                            },
                          ),
                          16.h,
                          TextFormField(
                            onTapOutside: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Contrasenya',
                              hintText: 'Contrasenya segura',
                              prefixIcon: const Icon(Icons.lock_outline),
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

                    // Botó principal
                    SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
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
                              ? 'Guardant entrada...'
                              : 'Guardar Entrada',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    24.h,

                    // Informació de seguretat
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
                              'Totes les dades es xifraran amb zero-knowledge abans de guardar-les de forma segura.',
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
