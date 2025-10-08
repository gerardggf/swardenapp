import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swardenapp/app/data/services/crypto_service.dart';
import 'package:swardenapp/app/domain/models/entry_model.dart';
import 'package:swardenapp/app/presentation/global/widgets/error_info_widget.dart';
import 'package:swardenapp/app/presentation/modules/auth/login_view.dart';
import 'package:swardenapp/app/presentation/modules/auth/register_view.dart';
import 'package:swardenapp/app/presentation/modules/edit_entry/edit_entry_view.dart';
import 'package:swardenapp/app/presentation/modules/entry/entry_view.dart';
import 'package:swardenapp/app/presentation/modules/home/home_view.dart';
import 'package:swardenapp/app/presentation/modules/new_entry/new_entry_view.dart';
import 'package:swardenapp/app/presentation/modules/splash_view.dart';
import 'package:swardenapp/app/presentation/modules/unlock_vault/unlock_vault_view.dart';
import 'package:swardenapp/app/presentation/controllers/session_controller.dart';
import '../../domain/models/user_model.dart';

/// Escolta canvis de Firebase Auth
final firebaseAuthStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Gestiona automàticament la càrrega de dades quan hi ha usuari de Firebase sense dades locals
final userManagerProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(firebaseAuthStateProvider);

  return await authState.when(
    loading: () async => null,
    error: (_, __) async => null,
    data: (firebaseUser) async {
      final sessionController = ref.read(sessionControllerProvider.notifier);
      final currentSessionUser = ref.read(sessionControllerProvider);

      if (firebaseUser != null) {
        // Hi ha usuari autenticat a Firebase
        if (currentSessionUser != null) {
          // Ja tenim les dades del usuari
          return currentSessionUser;
        } else {
          // Usuari autenticat però sense dades locals, les obenim
          await sessionController.restoreSession();
          return ref.read(sessionControllerProvider);
        }
      } else {
        // No hi ha usuari autenticat
        return null;
      }
    },
  );
});

final goRouterProvider = Provider<GoRouter>((ref) {
  // El router es reconstrueix quan canvia l'usuari gràcies al userManagerProvider
  ref.watch(userManagerProvider);

  return GoRouter(
    errorBuilder: (context, state) => const ErrorInfoWidget(),
    initialLocation: '/splash',
    redirect: (context, state) {
      final userAsync = ref.read(userManagerProvider);
      final cryptoService = ref.read(cryptoServiceProvider);
      final currentPath = state.uri.path;

      return userAsync.when(
        loading: () => currentPath == '/splash' ? null : '/splash',
        error: (_, __) => currentPath == '/login' ? null : '/login',

        /// Sempre que doni error, redirigim a login
        data: (user) {
          if (user != null) {
            // Usuari autenticat amb dades
            if (currentPath == '/splash' ||
                currentPath == '/login' ||
                currentPath == '/register') {
              // Redirigir a unlock-vault si la boveda està bloquejada
              return cryptoService.isVaultUnlocked ? '/home' : '/unlock-vault';
            }

            // Verificar si s'intenta accedir a pàgines que requereixen tenir la bóveda desbloquejada
            if (!cryptoService.isVaultUnlocked &&
                (currentPath == '/home' ||
                    currentPath == '/new-entry' ||
                    currentPath == '/entry')) {
              return '/unlock-vault';
            }
          } else {
            // Usuari no loggejat
            if (currentPath != '/login' && currentPath != '/register') {
              return '/login';
            }
          }
          return null;
        },
      );
    },
    routes: [
      GoRoute(
        name: SplashView.routeName,
        path: '/splash',
        builder: (context, state) => const SplashView(),
      ),

      GoRoute(
        name: RegisterView.routeName,
        path: '/register',
        builder: (context, state) => const RegisterView(),
      ),

      GoRoute(
        name: LoginView.routeName,
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),

      GoRoute(
        name: UnlockVaultView.routeName,
        path: '/unlock-vault',
        builder: (context, state) => const UnlockVaultView(),
      ),

      GoRoute(
        name: HomeView.routeName,
        path: '/home',

        builder: (context, state) => const HomeView(),
      ),

      GoRoute(
        name: NewEntryView.routeName,
        path: '/new-entry',

        builder: (context, state) => const NewEntryView(),
      ),
      GoRoute(
        name: EntryView.routeName,
        path: '/entry',
        builder: (context, state) =>
            EntryView(entry: state.extra as EntryDataModel),
      ),
      GoRoute(
        name: EditEntryView.routeName,
        path: '/edit-entry',
        builder: (context, state) =>
            EditEntryView(entryData: state.extra as EntryDataModel),
      ),
    ],
  );
});
