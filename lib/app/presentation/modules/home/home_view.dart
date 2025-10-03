import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inici')),
      body: const Center(child: Text('Benvingut a la pàgina d\'inici!')),
    );
  }
}
