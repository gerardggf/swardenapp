import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swardenapp/app/presentation/swarden_app.dart';

void main() async {
  // Assegurar que els widgets de Flutter estan inicialitzats
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialitzar Firebase
  await Firebase.initializeApp();

  // Executar l'aplicació amb Riverpod
  runApp(const ProviderScope(child: SwardenApp()));
}
