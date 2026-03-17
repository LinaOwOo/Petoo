import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:peto/core/theme/app_colors.dart';
import 'package:peto/features/auth/presentation/providers/auth_provider.dart';
import 'package:peto/features/auth/presentation/screens/login_screen.dart';
import 'package:peto/features/auth/presentation/screens/register_screen.dart';
import 'package:peto/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:peto/features/home/presentation/screens/home_screen.dart';
import 'package:peto/features/home/presentation/screens/pet_details_screen.dart';
import 'package:peto/features/care_tracker/presentation/screens/care_tracker_screen.dart';
import 'package:peto/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:peto/features/profile/presentation/screens/profile_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final currentPath = state.uri.toString();

      if (!isAuthenticated) {
        if (currentPath.startsWith('/home') ||
            currentPath.startsWith('/pet-details') ||
            currentPath == '/care-tracker' ||
            currentPath == '/calendar' ||
            currentPath == '/profile') {
          return '/login';
        }
        return null;
      }

      if (currentPath == '/login' || currentPath == '/register') {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/care-tracker',
        name: 'care-tracker',
        builder: (context, state) => const CareTrackerScreen(),
      ),
      GoRoute(
        path: '/calendar',
        name: 'calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/pet-details/:petId',
        name: 'pet-details',
        builder: (context, state) {
          final petId = state.pathParameters['petId']!;
          return PetDetailsScreen(petId: petId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.primaryBright,
            ),
            const SizedBox(height: 16),
            const Text(
              'Страница не найдена',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('На главную'),
            ),
          ],
        ),
      ),
    ),
  );
});
