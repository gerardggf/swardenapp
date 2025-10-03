import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swardenapp/app/presentation/controllers/session_controller.dart';
import 'package:swardenapp/app/presentation/global/widgets/error_info_widget.dart';
import 'package:swardenapp/app/presentation/modules/auth/login_view.dart';
import 'package:swardenapp/app/presentation/modules/auth/register_view.dart';
import 'package:swardenapp/app/presentation/modules/home/home_view.dart';
import 'package:swardenapp/app/presentation/modules/splash_view.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    errorBuilder: (context, state) => const ErrorInfoWidget(),
    initialLocation: '/splash',
    redirect: (context, state) {
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
