import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swardenapp/app/core/constants/global.dart';
import 'package:swardenapp/app/core/global_providers.dart';
import 'package:swardenapp/app/presentation/controllers/language_controller.dart';
import 'package:swardenapp/app/presentation/global/widgets/error_info_widget.dart';
import 'package:swardenapp/app/presentation/global/widgets/loading_widget.dart';
import 'package:swardenapp/app/presentation/routes/router.dart';
import 'package:swardenapp/app/presentation/theme.dart';
import '../core/generated/translations.g.dart';

/// Provider per inicialitzar l'aplicació i carregar les dependències necessàries abans d'iniciar
final appStartupProvider = FutureProvider<void>((ref) async {
  ref.onDispose(() {
    ref.invalidate(packageInfoProvider);
    ref.invalidate(sharedPreferencesProvider);
  });
  await ref.watch(packageInfoProvider.future);
  await ref.watch(sharedPreferencesProvider.future);
});

/// Widget que mostra l'estat d'inici de l'aplicació
class AppStartupWidget extends ConsumerWidget {
  const AppStartupWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStartupState = ref.watch(appStartupProvider);
    return appStartupState.when(
      data: (_) => const SwardenApp(),
      error: (e, __) => const AppStartupErrorWidget(),
      loading: () => const AppStartupLoadingWidget(),
    );
  }
}

/// Widget principal de l'aplicació
class SwardenApp extends ConsumerWidget {
  const SwardenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observar el locale actual des del language controller
    final currentLocale = ref.watch(languageControllerProvider);

    return MaterialApp.router(
      title: Global.appName,
      // Amagar el banner de debug
      debugShowCheckedModeBanner: false,
      // Localitzacions
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      //Idiomes suportats: Català, Castellà i Anglès
      supportedLocales: AppLocaleUtils.supportedLocales,
      // Locale de l'aplicació
      locale: currentLocale.flutterLocale,
      // Configuració de les rutes
      routerConfig: ref.watch(goRouterProvider),
      // Tema de l'aplicació
      theme: SwardenTheme.theme,
    );
  }
}

/// Widget que mostra un error en l'inici de l'aplicació
class AppStartupErrorWidget extends ConsumerWidget {
  const AppStartupErrorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GestureDetector(
          onTap: () {
            ref.invalidate(appStartupProvider);
          },
          child: ErrorInfoWidget(),
        ),
      ),
    );
  }
}

/// Widget que mostra una pantalla de càrrega durant l'inici de l'aplicació
class AppStartupLoadingWidget extends StatelessWidget {
  const AppStartupLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(backgroundColor: Colors.white, body: LoadingWidget()),
    );
  }
}
