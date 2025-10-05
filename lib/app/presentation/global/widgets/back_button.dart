import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SwardenBackButton extends StatelessWidget {
  const SwardenBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => context.pop(),
      icon: const Icon(Icons.chevron_left, size: 30),
      style: IconButton.styleFrom(backgroundColor: Colors.white),
    );
  }
}
