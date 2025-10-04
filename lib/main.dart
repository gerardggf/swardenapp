import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swardenapp/app/core/generated/translations.g.dart';
import 'package:swardenapp/app/presentation/swarden_app.dart';
import 'firebase_options.dart';

void main() async {
  // Assegurar que els widgets de Flutter estan inicialitzats
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialitzar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Executar l'aplicació amb Riverpod i suport per les traduccions
  runApp(TranslationProvider(child: const ProviderScope(child: SwardenApp())));
}
