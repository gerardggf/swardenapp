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

/// Provider que carga el estado del usuario actual usando authStateChanges
final userLoaderProvider = StreamProvider<UserModel?>((ref) {
  return FirebaseAuth.instance.authStateChanges().asyncMap((
    firebaseUser,
  ) async {
    if (firebaseUser != null) {
      // Si hay usuario en Firebase, devolver el usuario del sessionController
      final sessionUser = ref.read(sessionNotifierProvider);
      return sessionUser;
    }
    return null;
  });
});

/// Provider que indica si la app está cargando
final isLoadingProvider = Provider<bool>((ref) {
  final userAsyncValue = ref.watch(userLoaderProvider);
  return userAsyncValue.isLoading;
});

final goRouterProvider = Provider<GoRouter>((ref) {
  // Hacer que el router se reconstruya cuando cambie el estado del usuario
  ref.watch(userLoaderProvider);

  return GoRouter(
    errorBuilder: (context, state) => const ErrorInfoWidget(),
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoading = ref.read(isLoadingProvider);
      final userAsyncValue = ref.read(userLoaderProvider);
      final currentPath = state.uri.path;

      // Si estamos cargando, mantener en splash
      if (isLoading) {
        return '/splash';
      }

      // Si hay error, ir a login
      if (userAsyncValue.hasError) {
        if (currentPath != '/login') {
          return '/login';
        }
        return null;
      }

      // Si tenemos datos del usuario
      if (userAsyncValue.hasValue) {
        final user = userAsyncValue.value;

        // Si el usuario está autenticado
        if (user != null) {
          // Si está en splash, auth pages, redirigir a home
          if (currentPath == '/splash' ||
              currentPath == '/login' ||
              currentPath == '/register') {
            return '/home';
          }
        } else {
          // Si no está autenticado, ir a login
          if (currentPath != '/login' && currentPath != '/register') {
            return '/login';
          }
        }
      }

      return null;
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
