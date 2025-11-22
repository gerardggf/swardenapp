import 'package:flutter/material.dart';
import 'package:swardenapp/app/presentation/global/widgets/loading_widget.dart';

/// Vista de pantalla d'inici (splash)
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  static const routeName = '/splash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: const LoadingWidget()));
  }
}
