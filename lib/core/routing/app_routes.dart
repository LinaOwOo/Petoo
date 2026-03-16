import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:peto/core/theme/app_colors.dart';
import 'package:peto/features/home/presentation/screens/home_screen.dart';
import 'package:peto/features/home/presentation/screens/pet_details_screen.dart';
import 'package:peto/features/care_tracker/presentation/screens/care_tracker_screen.dart';
import 'package:peto/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:peto/features/auth/presentation/screens/profile_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/home';
  static const String careTracker = '/care-tracker';
  static const String calendar = '/calendar';
  static const String profile = '/profile';
  static const String petDetails = '/pet-details';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: careTracker,
        name: 'care-tracker',
        builder: (context, state) => const CareTrackerScreen(),
      ),
      GoRoute(
        path: calendar,
        name: 'calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '$petDetails/:petId',
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
            Text(
              'Страница не найдена',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(home),
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
}
