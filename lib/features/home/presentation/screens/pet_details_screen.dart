import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:peto/core/theme/app_colors.dart';
import 'package:peto/core/widgets/bottom_nav.dart';
import 'package:peto/features/home/presentation/providers/home_provider.dart';

// ============================================================================
// PetDetailsScreen - ConsumerWidget для реактивного получения данных
// Согласно архитектура.docx: данные через Riverpod, навигация через GoRouter
// ============================================================================
class PetDetailsScreen extends ConsumerWidget {
  final String petId;

  const PetDetailsScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pets = ref.watch(homeProvider).pets;
    final pet = pets.firstWhere(
      (p) => p['id'] == petId,
      orElse: () => {},
    );

    if (pet.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryBright),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Питомец не найден',
              style: TextStyle(color: AppColors.primaryBright)),
        ),
        body: const Center(
          child: Text(
            'Питомец не найден',
            style: TextStyle(color: AppColors.textGrey),
          ),
        ),
        bottomNavigationBar: const BottomNav(currentIndex: 0),
      );
    }

    final imagePath = pet['imagePath'] as String?;

    return Scaffold(
      backgroundColor: AppColors.background, // #F7FAFF из цвета.docx
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBright),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          pet['name'] as String? ?? 'Питомец',
          style: const TextStyle(
            color: AppColors.primaryBright, // #7EBCE8
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24), // UI Kit: единые отступы
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: imagePath != null && imagePath.isNotEmpty
                  ? Image.file(
                      File(imagePath),
                      height: 280,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                    )
                  : _buildPlaceholderImage(),
            ),
            const SizedBox(height: 24),
            // Порода и возраст
            Text(
              '${pet['breed'] as String? ?? 'Порода не указана'} • ${pet['age'] as String? ?? '—'}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textDark,
                  ),
            ),
            const SizedBox(height: 8),
            // Локация
            Text(
              pet['location'] as String? ?? '—',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textGrey,
                  ),
            ),
            const SizedBox(height: 32),
            // Статистика
            const Text('Статистика',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatCircle('2', 'года', AppColors.success),
                _StatCircle('3', 'вакцинации', AppColors.info),
                _StatCircle('95', '% активности', AppColors.warning),
              ],
            ),
            const SizedBox(height: 32),
            // Кнопки действий
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, // #B8D7EE
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Редактировать'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error, // #FFE8E8
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Удалить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 280,
      width: double.infinity,
      color: AppColors.surface,
      child: const Icon(Icons.pets, size: 80, color: AppColors.primaryBright),
    );
  }
}

// ============================================================================
// _StatCircle - переиспользуемый виджет статистики (DRY)
// ============================================================================
class _StatCircle extends StatelessWidget {
  final String value;
  final String label;
  final Color borderColor; // ✅ Цвет из цветовой схемы

  const _StatCircle(this.value, this.label,
      [this.borderColor = AppColors.primaryBright]);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 6), // UI Kit: акценты
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textGrey,
                )),
      ],
    );
  }
}
