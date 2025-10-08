import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swardenapp/app/core/constants/assets.dart';
import 'package:swardenapp/app/core/constants/colors.dart';
import 'package:swardenapp/app/core/extensions/num_to_sizedbox_extensions.dart';
import 'package:swardenapp/app/core/extensions/text_theme_extension.dart';
import 'package:swardenapp/app/core/generated/translations.g.dart';
import 'package:swardenapp/app/data/services/crypto_service.dart';
import 'package:swardenapp/app/presentation/controllers/session_controller.dart';
import 'package:swardenapp/app/presentation/global/dialogs.dart';
import 'package:swardenapp/app/presentation/global/functions/validators.dart';
import 'package:swardenapp/app/presentation/global/widgets/warning_widget.dart';
import 'package:swardenapp/app/presentation/modules/splash_view.dart';

class UnlockVaultView extends ConsumerStatefulWidget {
  static const String routeName = 'unlock-vault';

  const UnlockVaultView({super.key});

  @override
  ConsumerState<UnlockVaultView> createState() => _UnlockVaultViewState();
}

class _UnlockVaultViewState extends ConsumerState<UnlockVaultView> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _unlockVault() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final user = ref.read(sessionControllerProvider);
    if (user == null) {
      throw Exception('Usuari no trobat');
    }

    try {
      final cryptoService = ref.read(cryptoServiceProvider);
      final success = cryptoService.unlock(_passwordController.text, user);

      if (success) {
        context.goNamed(SplashView.routeName);
      } else {
        SwardenDialogs.snackBar(
          context,
          texts.auth.wrongPassword,
          isError: true,
        );
      }
    } catch (e) {
      SwardenDialogs.snackBar(
        context,
        '${texts.auth.anErrorHasOccurred}: $e',
        isError: true,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    try {
      final confirm = SwardenDialogs.dialog(
        context: context,
        title: texts.auth.logout,
        content: Text('Vols tancar sessió?'),
      );
      if (!await confirm) return;
      await ref.read(sessionControllerProvider.notifier).signOut();

      if (!mounted) return;
      context.goNamed(SplashView.routeName);
    } catch (e) {
      if (mounted) {
        SwardenDialogs.snackBar(
          context,
          texts.auth.anErrorHasOccurred,
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          Opacity(
            opacity: 0.2,
            child: Image.asset(
              Assets.bg,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary.withAlpha(24), Colors.white],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        30.h,

                        Icon(
                          Icons.lock_outline,
                          size: 80,
                          color: AppColors.primary,
                        ),
                        24.h,

                        Text(
                          'Bóveda Bloquejada',
                          style: context.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        8.h,

                        Text(
                          'Introdueix la teva contrasenya per desbloquejar les teves entrades',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        16.h,

                        Container(
                          padding: const EdgeInsets.all(16).copyWith(right: 5),
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
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primary.withAlpha(
                                  24,
                                ),
                                child: Icon(
                                  Icons.person_outline,
                                  color: AppColors.primary,
                                ),
                              ),
                              16.w,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.email ?? 'Usuari',
                                      style: context.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    4.h,
                                    Text(
                                      'Sessió activa',
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(
                                            color: Colors.green.shade600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: _signOut,
                                icon: Icon(
                                  Icons.logout_outlined,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),

                        20.h,

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
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.vpn_key_outlined,
                                      size: 20,
                                    ),
                                  ),
                                  12.w,
                                  Text(
                                    'Contrasenya Mestra',
                                    style: context.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              20.h,
                              TextFormField(
                                onTapOutside: (_) => FocusManager
                                    .instance
                                    .primaryFocus
                                    ?.unfocus(),
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                autofocus: true,
                                decoration: InputDecoration(
                                  labelText: 'Contrasenya',
                                  hintText:
                                      'Introdueix la teva contrasenya mestra',
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
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                validator: (value) =>
                                    Validators.validatePassword(value),
                                onFieldSubmitted: (_) => _unlockVault(),
                              ),
                            ],
                          ),
                        ),

                        20.h,

                        SizedBox(
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _unlockVault,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade600,
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
                                : const Icon(Icons.lock_open_outlined),
                            label: Text(
                              _isLoading
                                  ? 'Desbloquejant...'
                                  : 'Desbloquejar bóveda',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        20.h,
                        WarningWidget(
                          content:
                              'Les teves entrades estan protegides amb xifratge zero-knowledge. Només tu pots accedir-hi.',
                          icon: Icons.shield_outlined,
                          color: const Color.fromARGB(255, 28, 120, 195),
                          bgColor: Colors.blue.shade50,
                        ),

                        30.h,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
