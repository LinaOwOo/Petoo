import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peto/core/theme/app_colors.dart';
import 'package:peto/features/care_tracker/presentation/provider/care_tracker_provider.dart';
import 'package:peto/features/home/presentation/providers/home_provider.dart';
import 'package:peto/features/home/presentation/screens/home_screen.dart';
import 'package:peto/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:peto/features/profile/presentation/screen/profile_screen.dart';

class CareTrackerScreen extends ConsumerStatefulWidget {
  const CareTrackerScreen({super.key});

  @override
  ConsumerState<CareTrackerScreen> createState() => _CareTrackerScreenState();
}

class _CareTrackerScreenState extends ConsumerState<CareTrackerScreen> {
  int _navIndex = 1;

  @override
  Widget build(BuildContext context) {
    final careState = ref.watch(careTrackerProvider);
    final homeState = ref.watch(homeProvider);
    final pets = homeState.pets;

    final selectedPetId = careState.selectedPetId ??
        (pets.isNotEmpty ? pets.first['id'] as String? : null);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeader(pets, selectedPetId, careState),
            Expanded(
              child: pets.isEmpty || selectedPetId == null
                  ? _buildEmptyState()
                  : _buildTrackerContent(selectedPetId, careState),
            ),
            _buildBottomNavBar(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    List<Map<String, dynamic>> pets,
    String? selectedPetId,
    CareTrackerState careState,
  ) {
    if (pets.isEmpty) {
      return _buildEmptyHeader();
    }

    final selectedPet = pets.firstWhere(
      (p) => p['id'] == selectedPetId,
      orElse: () => pets.first,
    );

    final currentIndex = pets.indexWhere((p) => p['id'] == selectedPetId);
    final hasPrev = currentIndex > 0;
    final hasNext = currentIndex < pets.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (hasPrev)
            IconButton(
              icon: const Icon(Icons.chevron_left,
                  color: AppColors.primaryBright),
              onPressed: () {
                final prevId = pets[currentIndex - 1]['id'] as String;
                ref.read(careTrackerProvider.notifier).selectPet(prevId);
              },
            ),
          SvgPicture.asset(
            _getPetIcon(selectedPet['category'] as String?),
            width: 32,
            height: 32,
            colorFilter: const ColorFilter.mode(
              AppColors.primaryBright,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            selectedPet['name'] as String? ?? 'PetCare',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBright,
            ),
          ),
          const SizedBox(width: 12),
          if (hasNext)
            IconButton(
              icon: const Icon(Icons.chevron_right,
                  color: AppColors.primaryBright),
              onPressed: () {
                final nextId = pets[currentIndex + 1]['id'] as String;
                ref.read(careTrackerProvider.notifier).selectPet(nextId);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets_outlined, size: 32, color: AppColors.primaryBright),
          SizedBox(width: 12),
          Text(
            'Трекер ухода',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  String _getPetIcon(String? category) {
    switch (category) {
      case 'Кошки':
        return 'assets/icons/blue_cat.svg';
      case 'Собаки':
        return 'assets/icons/blue_dog.svg';
      case 'Черепашки':
        return 'assets/icons/blue_turtle.svg';
      case 'Кролики':
        return 'assets/icons/blue_rabbit.svg';
      default:
        return 'assets/icons/blue_dog.svg';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pets_outlined,
                size: 64,
                color: AppColors.primaryBright.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Нет питомцев',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Добавьте питомца на главном экране,\nчтобы отслеживать уход',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGrey.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Добавить питомца'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackerContent(String petId, CareTrackerState state) {
    final todayTasks = state.getTodayTasks(petId);
    final weekTasks = state.getWeekTasks(petId);
    final waterCount = state.waterCounts[petId] ?? 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildCareCard(
            icon: 'assets/icons/bowl_food.svg',
            iconColor: AppColors.success,
            bgColor: AppColors.success.withValues(alpha: 0.15),
            title: 'Кормление',
            stats: '${todayTasks.where((t) => t.type == 'food').length}/3',
            lastUpdate:
                _getLastUpdate(weekTasks.where((t) => t.type == 'food')),
            frequency: 'Каждый день',
            petId: petId,
            type: 'food',
          ),
          const SizedBox(height: 16),
          _buildCareCard(
            icon: 'assets/icons/bowl_water.svg',
            iconColor: AppColors.primary,
            bgColor: AppColors.info,
            title: 'Вода',
            stats: '$waterCount Миска',
            lastUpdate:
                _getLastUpdate(weekTasks.where((t) => t.type == 'water')),
            frequency: 'Каждый день',
            petId: petId,
            type: 'water',
          ),
          const SizedBox(height: 16),
          _buildCareCard(
            icon: 'assets/icons/trey.svg',
            iconColor: AppColors.secondary,
            bgColor: AppColors.secondary.withValues(alpha: 0.15),
            title: 'Туалет',
            stats: '',
            lastUpdate:
                _getLastUpdate(weekTasks.where((t) => t.type == 'toilet')),
            frequency: 'По необходимости',
            petId: petId,
            type: 'toilet',
          ),
        ],
      ),
    );
  }

  String _getLastUpdate(Iterable<CareTask> tasks) {
    if (tasks.isEmpty) return 'На неделе';
    final lastTask = tasks.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
    final diff = DateTime.now().difference(lastTask.date).inDays;
    if (diff == 0) return 'Сегодня';
    if (diff == 1) return 'Вчера';
    if (diff < 7) return '$diff дн. назад';
    return 'На неделе';
  }

  Widget _buildCareCard({
    required String icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String stats,
    required String lastUpdate,
    required String frequency,
    required String petId,
    required String type,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SvgPicture.asset(
              icon,
              width: 68,
              height: 68,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (stats.isNotEmpty) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          stats,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textDark,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _handlePlus(petId, type),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: iconColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                _buildInfoRow('Мыли', lastUpdate),
                const SizedBox(height: 8),
                _buildInfoRow('Обновление', frequency),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _handleUpdate(petId, type),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: iconColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: iconColor, width: 1.5),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Обновить',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _handlePlus(String petId, String type) {
    if (type == 'water') {
      ref.read(careTrackerProvider.notifier).incrementWater(petId);
    } else {
      final task = CareTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        petId: petId,
        type: type,
        date: DateTime.now(),
      );
      ref.read(careTrackerProvider.notifier).addTask(task);
    }
  }

  void _handleUpdate(String petId, String type) {
    final task = CareTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      petId: petId,
      type: type,
      date: DateTime.now(),
    );
    ref.read(careTrackerProvider.notifier).addTask(task);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Обновлено: $type'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildBottomNavBar() {
    const navItems = [
      'assets/icons/home.svg',
      'assets/icons/target.svg',
      'assets/icons/calendar.svg',
      'assets/icons/profile.svg',
    ];

    return Container(
      margin: const EdgeInsets.all(20),
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(navItems.length, (index) {
          return GestureDetector(
            onTap: () => _navigateToScreen(index),
            child: SvgPicture.asset(
              navItems[index],
              width: 28,
              height: 28,
              colorFilter: ColorFilter.mode(
                index == _navIndex
                    ? AppColors.primaryBright
                    : AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
          );
        }),
      ),
    );
  }

  void _navigateToScreen(int index) {
    if (index == _navIndex) return;

    setState(() => _navIndex = index);

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case 2:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CalendarScreen()),
        );
        break;
      case 3:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }
}
