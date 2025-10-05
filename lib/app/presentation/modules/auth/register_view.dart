import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swardenapp/app/core/constants/colors.dart';
import 'package:swardenapp/app/core/constants/urls.dart';
import 'package:swardenapp/app/core/extensions/num_to_sizedbox_extensions.dart';
import 'package:swardenapp/app/core/extensions/swarden_exceptions_extensions.dart';
import 'package:swardenapp/app/core/extensions/text_theme_extension.dart';
import 'package:swardenapp/app/domain/either/either.dart';
import 'package:swardenapp/app/presentation/global/dialogs.dart';
import 'package:swardenapp/app/presentation/global/functions/launch_url.dart';
import 'package:swardenapp/app/presentation/global/functions/validators.dart';
import 'package:swardenapp/app/presentation/global/widgets/back_button.dart';
import 'package:swardenapp/app/presentation/global/widgets/warning_widget.dart';
import '../../controllers/session_controller.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  static const routeName = 'register';

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _acceptsPrivacyPolicy = false;
  bool _obscurePswrd = true;
  bool _obscureConfirmPswrd = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SwardenBackButton(),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary.withAlpha(24), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    40.h,

                    // Logo i títol principal
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(24),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person_add_outlined, size: 60),
                        ),
                        24.h,
                        Text(
                          'Crea el teu compte',
                          style: context.headlineThemeM?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        8.h,
                        Text(
                          'Registra\'t per comen\u00e7ar a gestionar les teves contrasenyes de forma segura',
                          style: context.bodyThemeM?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    40.h,

                    // Camp email
                    TextFormField(
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
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
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppColors.primary,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        helperText: 'Aquest serà el teu identificador únic',
                        helperStyle: TextStyle(color: Colors.grey.shade600),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => Validators.validateEmail(value),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    20.h,

                    // Camp contrasenya
                    TextFormField(
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: 'Contrasenya',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
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
                        prefixIcon: Icon(
                          Icons.lock_outlined,
                          color: AppColors.primary,
                        ),
                        suffixIcon: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            setState(() {
                              _obscurePswrd = !_obscurePswrd;
                            });
                          },
                          child: Icon(
                            _obscurePswrd
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.primary,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        helperText: 'Mínim 6 caràcters',
                        helperStyle: TextStyle(color: Colors.grey.shade600),
                      ),
                      obscureText: _obscurePswrd,
                      validator: (value) => Validators.validatePassword(value),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    20.h,

                    // Camp confirmar contrasenya
                    TextFormField(
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        hintText: 'Confirmar Contrasenya',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
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
                        suffixIcon: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            setState(() {
                              _obscureConfirmPswrd = !_obscureConfirmPswrd;
                            });
                          },
                          child: Icon(
                            _obscureConfirmPswrd
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.primary,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: AppColors.primary,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      obscureText: _obscureConfirmPswrd,
                      validator: (value) => Validators.validateConfirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    24.h,
                    WarningWidget(
                      title: 'IMPORTANT',
                      content:
                          'La contrasenya no es podrà canviar després del registre. Assegura\'t que la recordis!',
                      icon: Icons.warning_amber,
                    ),
                    20.h,

                    // Checkbox política de privacitat
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptsPrivacyPolicy,
                          onChanged: (value) {
                            setState(() {
                              _acceptsPrivacyPolicy = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _acceptsPrivacyPolicy = !_acceptsPrivacyPolicy;
                              });
                            },
                            child: InkWell(
                              onTap: () {
                                launchCustomUrl(Urls.privacyPolicy);
                              },
                              child: RichText(
                                text: TextSpan(
                                  style: context.bodyThemeM,
                                  children: [
                                    const TextSpan(
                                      text: 'He llegit i accepto la ',
                                    ),
                                    TextSpan(
                                      text: 'Política de Privacitat',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const TextSpan(text: '.'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    24.h,

                    // Botó de registre
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: _acceptsPrivacyPolicy
                            ? LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withAlpha(180),
                                ],
                              )
                            : null,
                        color: _acceptsPrivacyPolicy
                            ? null
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _acceptsPrivacyPolicy
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withAlpha(40),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: ElevatedButton(
                        onPressed: (_isLoading || !_acceptsPrivacyPolicy)
                            ? null
                            : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Registrar-se',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _acceptsPrivacyPolicy
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                ),
                              ),
                      ),
                    ),

                    60.h,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    /// Validem el formulari
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptsPrivacyPolicy) {
      SwardenDialogs.snackBar(
        context,
        'Has d\'acceptar la Política de Privacitat per continuar',
        isWarning: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final result = await ref
        .read(sessionControllerProvider.notifier)
        .register(email, password);

    result.when(
      left: (e) {
        SwardenDialogs.snackBar(context, e.toText(), isError: true);
      },
      right: (user) {
        // No fem res aquí, ja que el router redirigeix automàticament
      },
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
