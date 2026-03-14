import 'package:flutter/material.dart';
import 'package:peto/core/theme/app_colors.dart';
import 'package:peto/features/auth/presentation/screens/home_screen.dart';
import 'package:peto/features/auth/presentation/screens/profile_screen.dart';

class PetDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> pet;

  const PetDetailsScreen({required this.pet, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(pet['name']!,
            style: Theme.of(context).textTheme.headlineLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                pet['image']!,
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${pet['breed']} • ${pet['age']}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              pet['location']!,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 32),
            const Text('Статистика',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatCircle('2', 'года'),
                _StatCircle('3', 'вакцинации'),
                _StatCircle('95', '% активности'),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;

          if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
          if (index == 3) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Экран в разработке')),
            );
          }
        },
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textGrey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/home.svg', width: 24),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/target.svg', width: 24),
            label: 'Поиск',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/calendar.svg', width: 24),
            label: 'Календарь',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/profile.svg', width: 24),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

class _StatCircle extends StatelessWidget {
  final String value;
  final String label;

  const _StatCircle(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryBright, width: 6),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
