import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swardenapp/app/core/constants/assets.dart';
import 'package:swardenapp/app/core/constants/colors.dart';
import 'package:swardenapp/app/core/constants/urls.dart';
import 'package:swardenapp/app/core/extensions/num_to_sizedbox_extensions.dart';
import 'package:swardenapp/app/core/extensions/swarden_exceptions_extensions.dart';
import 'package:swardenapp/app/core/extensions/text_theme_extension.dart';
import 'package:swardenapp/app/core/generated/translations.g.dart';
import 'package:swardenapp/app/core/utils/either/either.dart';
import 'package:swardenapp/app/presentation/global/dialogs/dialogs.dart';
import 'package:swardenapp/app/presentation/global/functions/launch_url.dart';
import 'package:swardenapp/app/presentation/global/functions/validators.dart';
import 'package:swardenapp/app/presentation/global/widgets/back_button.dart';
import 'package:swardenapp/app/presentation/global/widgets/warning_widget.dart';
import '../../controllers/session_controller.dart';

/// Vista per a la pantalla de registre d'usuari
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
  final _vaultPasswordController = TextEditingController();
  final _confirmVaultPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _acceptsPrivacyPolicy = false;
  bool _obscurePswrd = true;
  bool _obscureConfirmPswrd = true;
  bool _obscureVaultPswrd = true;
  bool _obscureConfirmVaultPswrd = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SwardenBackButton(),
      ),
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
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        40.h,
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
                              texts.auth.createYourAccount,
                              style: context.themeHM?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            8.h,
                            Text(
                              texts.auth.registerSubtitle,
                              style: context.themeBM?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        40.h,

                        TextFormField(
                          onTapOutside: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: texts.auth.email,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
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
                            helperText: texts.auth.emailHelperText,
                            helperStyle: TextStyle(color: Colors.grey.shade600),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => Validators.validateEmail(value),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        20.h,

                        TextFormField(
                          onTapOutside: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          controller: _passwordController,
                          decoration: InputDecoration(
                            hintText: texts.auth.password,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
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
                            helperText: texts.auth.passwordMinChars,
                            helperStyle: TextStyle(color: Colors.grey.shade600),
                          ),
                          obscureText: _obscurePswrd,
                          validator: (value) =>
                              Validators.validatePassword(value),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        20.h,

                        TextFormField(
                          onTapOutside: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            hintText: texts.auth.confirmPassword,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
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
                          validator: (value) =>
                              Validators.validateConfirmPassword(
                                value,
                                _passwordController.text,
                              ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        24.h,

                        Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                texts.auth.vaultPasswordDivider,
                                style: context.themeBM?.copyWith(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        16.h,
                        WarningWidget(
                          color: const Color.fromARGB(255, 18, 132, 147),
                          bgColor: Colors.blue.shade50,
                          content: texts.auth.vaultPasswordWarning,
                          icon: Icons.shield,
                        ),

                        20.h,

                        TextFormField(
                          onTapOutside: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          controller: _vaultPasswordController,
                          decoration: InputDecoration(
                            hintText: texts.auth.vaultPasswordHint,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.security_outlined,
                              color: AppColors.primary,
                            ),
                            suffixIcon: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () {
                                setState(() {
                                  _obscureVaultPswrd = !_obscureVaultPswrd;
                                });
                              },
                              child: Icon(
                                _obscureVaultPswrd
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.primary,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            helperText: texts.auth.vaultPasswordHelperText,
                            helperStyle: TextStyle(color: Colors.grey.shade600),
                          ),
                          obscureText: _obscureVaultPswrd,
                          validator: (value) =>
                              Validators.validatePassword(value),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        20.h,

                        TextFormField(
                          onTapOutside: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          controller: _confirmVaultPasswordController,
                          decoration: InputDecoration(
                            hintText: texts.auth.confirmVaultPassword,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
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
                                  _obscureConfirmVaultPswrd =
                                      !_obscureConfirmVaultPswrd;
                                });
                              },
                              child: Icon(
                                _obscureConfirmVaultPswrd
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.primary,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.security_outlined,
                              color: AppColors.primary,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          obscureText: _obscureConfirmVaultPswrd,
                          validator: (value) =>
                              Validators.validateConfirmPassword(
                                value,
                                _vaultPasswordController.text,
                              ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        24.h,

                        WarningWidget(
                          title: texts.auth.importantWarningTitle,
                          content: texts.auth.importantWarningContent,
                          icon: Icons.warning_amber,
                        ),
                        20.h,

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
                                    _acceptsPrivacyPolicy =
                                        !_acceptsPrivacyPolicy;
                                  });
                                },
                                child: InkWell(
                                  onTap: () {
                                    launchCustomUrl(Urls.privacyPolicy);
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      style: context.themeBM,
                                      children: [
                                        TextSpan(
                                          text: texts.auth.iHaveReadAndAccept,
                                        ),
                                        TextSpan(
                                          text: texts.auth.privacyPolicyLink,
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            decoration:
                                                TextDecoration.underline,
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
                                    texts.auth.registerButton,
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
        ],
      ),
    );
  }

  Future<void> _register() async {
    /// Validació del formulari
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptsPrivacyPolicy) {
      SwardenDialogs.snackBar(
        context,
        texts.auth.mustAcceptPrivacyPolicy,
        isWarning: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final vaultPassword = _vaultPasswordController.text.trim();

    final result = await ref
        .read(sessionControllerProvider.notifier)
        .register(email, password, vaultPassword);

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
    _vaultPasswordController.dispose();
    _confirmVaultPasswordController.dispose();
    super.dispose();
  }
}
