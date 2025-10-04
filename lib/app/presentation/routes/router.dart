import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swardenapp/app/presentation/global/widgets/error_info_widget.dart';
import 'package:swardenapp/app/presentation/modules/auth/login_view.dart';
import 'package:swardenapp/app/presentation/modules/auth/register_view.dart';
import 'package:swardenapp/app/presentation/modules/home/home_view.dart';
import 'package:swardenapp/app/presentation/modules/splash_view.dart';
import 'package:swardenapp/app/presentation/controllers/session_controller.dart';
import '../../domain/models/user_model.dart';

/// Simplement escolta Firebase Auth
final firebaseAuthStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Gestiona automàticament la càrrega de dades quan hi ha usuari de Firebase sense dades locals
final userManagerProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(firebaseAuthStateProvider);

  return await authState.when(
    loading: () async => null,
    error: (error, stack) async => null,
    data: (firebaseUser) async {
      final sessionController = ref.read(sessionControllerProvider.notifier);
      final currentSessionUser = ref.read(sessionControllerProvider);

      if (firebaseUser != null) {
        // Hi ha usuari autenticat a Firebase
        if (currentSessionUser != null) {
          // Ja tenim les dades, tot correcte
          return currentSessionUser;
        } else {
          // Usuari autenticat però sense dades locals, restaurem
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
  // El router es reconstrueix quan canvia l'usuari
  ref.watch(userManagerProvider);

  return GoRouter(
    errorBuilder: (context, state) => const ErrorInfoWidget(),
    initialLocation: '/splash',
    redirect: (context, state) {
      final userAsync = ref.read(userManagerProvider);
      final currentPath = state.uri.path;
      return userAsync.when(
        loading: () => currentPath == '/splash' ? null : '/splash',
        error: (error, stack) => currentPath == '/login' ? null : '/login',
        data: (user) {
          if (user != null) {
            // Usuari autenticat amb dades
            if (currentPath == '/splash' ||
                currentPath == '/login' ||
                currentPath == '/register') {
              return '/home';
            }
          } else {
            // Sense usuari
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

      // Rutes principals de l'app
      GoRoute(
        name: HomeView.routeName,
        path: '/home',

        builder: (context, state) => const HomeView(),
      ),
    ],
  );
});
