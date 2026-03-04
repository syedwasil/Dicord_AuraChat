import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme.dart';
import 'core/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    // ProviderScope is required for Riverpod
    const ProviderScope(child: AuraChatApp()),
  );
}

class AuraChatApp extends ConsumerWidget {
  const AuraChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'AuraChat',
      theme: AuraTheme.darkTheme,
      themeMode: ThemeMode.dark, // Enforce dark mode
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
