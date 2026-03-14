import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart'; // ← Добавить для навигации
import 'dart:io';
import 'package:peto/core/theme/app_colors.dart';
import '../providers/home_provider.dart';

// ✅ ИЗМЕНЕНО: ConsumerWidget → ConsumerStatefulWidget для хранения _navIndex
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0; // ✅ Теперь это поле состояния доступно

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);
    final allPets = state.pets;
    final selectedCategory = state.category;

    final filteredPets = selectedCategory == 'Все'
        ? allPets
        : allPets.where((p) => p['category'] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildMiniCalendar(),
              const SizedBox(height: 24),
              _buildCategoryFilter(ref, selectedCategory),
              const SizedBox(height: 24),
              Expanded(
                child: _buildPetGrid(ref, filteredPets),
              ),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 24),
              _buildBottomNavBar(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniCalendar() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekDates = List.generate(7, (i) => monday.add(Duration(days: i)));
    const dayNames = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          final isToday = weekDates[index].day == now.day &&
              weekDates[index].month == now.month;

          return Column(
            children: [
              Text(
                dayNames[index],
                style: TextStyle(
                  color: AppColors.textDark.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${weekDates[index].day}',
                style: TextStyle(
                  color: isToday
                      ? AppColors.primaryBright
                      : AppColors.textDark.withValues(alpha: 0.6),
                  fontSize: 18,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCategoryFilter(WidgetRef ref, String selectedCategory) {
    final categories = [
      {'label': 'Все', 'icon': 'assets/icons/blue_dog.svg'},
      {'label': 'Кошки', 'icon': 'assets/icons/blue_cat.svg'},
      {'label': 'Собаки', 'icon': 'assets/icons/blue_dog.svg'},
      {'label': 'Черепашки', 'icon': 'assets/icons/blue_turtle.svg'},
      {'label': 'Кролики', 'icon': 'assets/icons/blue_rabbit.svg'},
    ];

    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['label'];

          return GestureDetector(
            onTap: () =>
                ref.read(homeProvider.notifier).setCategory(category['label']!),
            child: Container(
              width: category['label'] == 'Все' ? 70 : 56,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: category['label'] == 'Все'
                  ? const Center(
                      child: Text(
                        'All',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    )
                  : Center(
                      child: SvgPicture.asset(
                        category['icon']!,
                        width: 28,
                        height: 28,
                        colorFilter: ColorFilter.mode(
                          isSelected ? Colors.white : AppColors.primaryBright,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPetGrid(WidgetRef ref, List<Map<String, dynamic>> pets) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: pets.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildAddCard(context, ref);
        }
        return _buildPetCard(context, pets[index - 1], index - 1);
      },
    );
  }

  Widget _buildAddCard(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showAddPetModal(context, ref),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            size: 36,
            color: AppColors.primaryBright,
          ),
        ),
      ),
    );
  }

  Widget _buildPetCard(
      BuildContext context, Map<String, dynamic> pet, int index) {
    const colors = {
      'Кошки': AppColors.secondary,
      'Собаки': Color(0xFFE8C885),
      'Черепашки': AppColors.success,
      'Кролики': AppColors.primary,
    };

    final color = colors[pet['category']] ?? AppColors.surface;
    final imagePath = pet['imagePath'] as String?;

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Экран питомца в разработке'),
            backgroundColor: AppColors.info,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  if (imagePath != null && imagePath.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  else
                    const Center(
                      child: Icon(
                        Icons.pets,
                        size: 48,
                        color: AppColors.primaryBright,
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star,
                        color: AppColors.warning,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.info,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.pets, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      pet['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatIndicators(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatIndicators() {
    return Row(
      children: [
        _buildDot(AppColors.success),
        _buildDot(AppColors.primary),
        _buildDot(AppColors.secondary),
      ],
    );
  }

  static Widget _buildDot(Color color) {
    return Container(
      width: 7,
      height: 7,
      margin: const EdgeInsets.only(left: 3),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          icon: Icons.medical_services_outlined,
          color: AppColors.success,
          onTap: () {},
        ),
        _buildActionButton(
          icon: Icons.shower_outlined,
          color: AppColors.info,
          onTap: () {},
        ),
        _buildActionButton(
          icon: Icons.water_drop_outlined,
          color: AppColors.secondary,
          onTap: () {},
        ),
        _buildActionButton(
          icon: Icons.add,
          color: AppColors.warning,
          onTap: () {},
        ),
      ],
    );
  }

  static Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, int index) {
    final routes = ['/home', '/care-tracker', '/calendar', '/profile'];
    if (index >= 0 && index < routes.length) {
      context.go(routes[index]);
    }
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
            onTap: () {
              setState(() => _navIndex = index);
              _navigateToScreen(context, index);
            },
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

  void _showAddPetModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddPetForm(ref: ref),
    );
  }
}

class _AddPetForm extends StatefulWidget {
  final WidgetRef ref;

  const _AddPetForm({required this.ref});

  @override
  State<_AddPetForm> createState() => _AddPetFormState();
}

class _AddPetFormState extends State<_AddPetForm> {
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  String _selectedCat = 'Кошки';
  DateTime? _birthDate;
  String? _imagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Новый питомец',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.primaryBright,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textGrey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPhotoPicker(),
          const SizedBox(height: 24),
          _buildCategorySelector(),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _nameController,
            hintText: 'Кличка',
            icon: Icons.pets,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _breedController,
            hintText: 'Порода',
            icon: Icons.info,
          ),
          const SizedBox(height: 16),
          _buildDatePicker(),
          const SizedBox(height: 24),
          _buildSaveButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return GestureDetector(
      onTap: () async {
        final ImagePicker picker = ImagePicker();
        final XFile? photo =
            await picker.pickImage(source: ImageSource.gallery);
        if (photo != null) {
          setState(() => _imagePath = photo.path);
        }
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: _imagePath != null ? Colors.transparent : AppColors.info,
          borderRadius: BorderRadius.circular(20),
          image: _imagePath != null
              ? DecorationImage(
                  image: FileImage(File(_imagePath!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _imagePath == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 32,
                    color: AppColors.primaryBright,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Фото',
                    style: TextStyle(
                      color: AppColors.primaryBright,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = [
      {'name': 'Кошки', 'icon': 'assets/icons/blue_cat.svg'},
      {'name': 'Собаки', 'icon': 'assets/icons/blue_dog.svg'},
      {'name': 'Черепашки', 'icon': 'assets/icons/blue_turtle.svg'},
      {'name': 'Кролики', 'icon': 'assets/icons/blue_rabbit.svg'},
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text(
        'Тип питомца',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textGrey,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: categories.map((category) {
          final isSelected = _selectedCat == category['name'];
          final iconPath = category['icon'] as String;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCat = category['name'] as String;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isSelected ? AppColors.primaryBright : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  SvgPicture.asset(
                    iconPath,
                    width: 32,
                    height: 32,
                    colorFilter: ColorFilter.mode(
                      isSelected ? Colors.white : AppColors.primaryBright,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category['name'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ]);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.primaryBright),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now().subtract(const Duration(days: 365)),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primaryBright,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => _birthDate = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(20),
          color: AppColors.background,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.primaryBright,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _birthDate == null
                  ? 'Выбрать дату рождения'
                  : '${_birthDate!.day}.${_birthDate!.month}.${_birthDate!.year}',
              style: TextStyle(
                color: _birthDate == null
                    ? AppColors.primaryBright
                    : AppColors.textDark,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          if (_nameController.text.isEmpty ||
              _breedController.text.isEmpty ||
              _birthDate == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Заполните все обязательные поля'),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }
          final years =
              ((DateTime.now().difference(_birthDate!).inDays) / 365).floor();
          final ageStr =
              '$years ${years == 1 ? "год" : years < 5 ? "года" : "лет"}';

          widget.ref.read(homeProvider.notifier).addPet({
            'name': _nameController.text,
            'breed': _breedController.text,
            'age': ageStr,
            'location': 'Москва',
            'imagePath': _imagePath,
            'category': _selectedCat,
          });
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        child: const Text('Сохранить питомца'),
      ),
    );
  }
}
