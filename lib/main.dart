import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peto/core/routing/app_routes.dart'; // ✅ Импорт роутера
import 'package:peto/core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: PetPlanetApp()));
}

class PetPlanetApp extends ConsumerWidget {
  const PetPlanetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      // ✅ router вместо обычного MaterialApp
      title: 'PetPlanet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRoutes.router, // ✅ Подключение GoRouter
    );
  }
}
