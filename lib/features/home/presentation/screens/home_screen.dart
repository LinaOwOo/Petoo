import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:peto/core/theme/app_colors.dart';
import 'package:peto/core/routing/app_routes.dart';
import 'package:peto/features/home/presentation/providers/home_provider.dart';
import 'package:peto/core/widgets/bottom_nav.dart';
import 'package:peto/features/calendar/presentation/providers/calendar_provider.dart';

enum AppointmentType { clinic, grooming, vaccination, other }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);

    final filteredPets = state.category == 'Все'
        ? state.pets
        : state.pets.where((p) {
            final category = p['category'] as String?;
            return category != null && category == state.category;
          }).toList();

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
              _buildCategoryFilter(ref, state.category),
              const SizedBox(height: 24),
              Expanded(child: _buildPetGrid(filteredPets)),
              const SizedBox(height: 24),
              _buildActionButtons(context),
              const SizedBox(height: 24),
              const BottomNav(currentIndex: 0),
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
            onTap: () => ref
                .read(homeProvider.notifier)
                .setCategory(category['label'] as String),
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
                            fontSize: 15),
                      ),
                    )
                  : Center(
                      child: SvgPicture.asset(
                        category['icon'] as String,
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

  Widget _buildPetGrid(List<Map<String, dynamic>> pets) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: pets.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildAddCard(context);
        return _buildPetCard(context, pets[index - 1]);
      },
    );
  }

  Widget _buildAddCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddPetModal(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: const Center(
            child: Icon(Icons.add, size: 36, color: AppColors.primaryBright)),
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, Map<String, dynamic> pet) {
    const colors = {
      'Кошки': AppColors.secondary,
      'Собаки': Color(0xFFE8C885),
      'Черепашки': AppColors.success,
      'Кролики': AppColors.primary,
    };

    final category = pet['category'] as String?;
    final color = category != null
        ? (colors[category] ?? AppColors.surface)
        : AppColors.surface;

    final imagePath = pet['imagePath'] as String?;
    final petId = pet['id'] as String?;

    return GestureDetector(
      onTap: () {
        if (petId != null && context.mounted) {
          context.go('${AppRoutes.petDetails}/$petId');
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Экран питомца в разработке'),
                backgroundColor: AppColors.info),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4)),
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
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Image.file(File(imagePath),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity),
                    )
                  else
                    const Center(
                        child: Icon(Icons.pets,
                            size: 48, color: AppColors.primaryBright)),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.star,
                          color: AppColors.warning, size: 14),
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
                    bottomRight: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.pets, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      pet['name'] as String? ?? 'Без имени',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
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
    return Row(children: [
      _buildDot(AppColors.success),
      _buildDot(AppColors.primary),
      _buildDot(AppColors.secondary),
    ]);
  }

  static Widget _buildDot(Color color) {
    return Container(
      width: 7,
      height: 7,
      margin: const EdgeInsets.only(left: 3),
      decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1)),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
            icon: Icons.medical_services_outlined,
            color: AppColors.success,
            onTap: () => _showAppointmentModal(
                context, AppointmentType.clinic, 'Ветеринарная клиника')),
        _buildActionButton(
            icon: Icons.shower_outlined,
            color: AppColors.info,
            onTap: () => _showAppointmentModal(
                context, AppointmentType.grooming, 'Груминг')),
        _buildActionButton(
            icon: Icons.water_drop_outlined,
            color: AppColors.secondary,
            onTap: () => _showAppointmentModal(
                context, AppointmentType.vaccination, 'Прививки')),
        _buildActionButton(
            icon: Icons.add,
            color: AppColors.warning,
            onTap: () => _showAppointmentModal(
                context, AppointmentType.other, 'Другое')),
      ],
    );
  }

  static Widget _buildActionButton(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
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
                offset: const Offset(0, 4))
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  void _showAddPetModal(BuildContext context) {
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _AddPetForm(ref: ref),
    );
  }

  void _showAppointmentModal(
      BuildContext context, AppointmentType type, String title) {
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _AppointmentForm(type: type, title: title),
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
          top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFormHeader('Новый питомец'),
          const SizedBox(height: 24),
          _buildPhotoPicker(),
          const SizedBox(height: 24),
          _buildCategorySelector(),
          const SizedBox(height: 16),
          _buildTextField(_nameController, 'Кличка', Icons.pets),
          const SizedBox(height: 16),
          _buildTextField(_breedController, 'Порода', Icons.info),
          const SizedBox(height: 16),
          _buildDatePicker(),
          const SizedBox(height: 24),
          _buildSaveButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFormHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBright)),
        IconButton(
            icon: const Icon(Icons.close, color: AppColors.textGrey),
            onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _buildPhotoPicker() {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final photo = await picker.pickImage(source: ImageSource.gallery);
        if (photo != null && mounted) setState(() => _imagePath = photo.path);
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: _imagePath != null ? Colors.transparent : AppColors.info,
          borderRadius: BorderRadius.circular(20),
          image: _imagePath != null
              ? DecorationImage(
                  image: FileImage(File(_imagePath!)), fit: BoxFit.cover)
              : null,
        ),
        child: _imagePath == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Icon(Icons.add_photo_alternate,
                        size: 32, color: AppColors.primaryBright),
                    SizedBox(height: 4),
                    Text('Фото',
                        style: TextStyle(
                            color: AppColors.primaryBright, fontSize: 12)),
                  ])
            : null,
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = ['Кошки', 'Собаки', 'Черепашки', 'Кролики'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Тип питомца',
            style: TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categories.map((category) {
            final isSelected = _selectedCat == category;
            return GestureDetector(
              onTap: () => setState(() => _selectedCat = category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBright
                          : Colors.transparent,
                      width: 2),
                ),
                child: Column(
                  children: [
                    Icon(_getCategoryIcon(category),
                        size: 24,
                        color: isSelected
                            ? Colors.white
                            : AppColors.primaryBright),
                    const SizedBox(height: 4),
                    Text(category,
                        style: TextStyle(
                            color:
                                isSelected ? Colors.white : AppColors.textDark,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Кошки':
        return Icons.pets;
      case 'Собаки':
        return Icons.pets;
      case 'Черепашки':
        return Icons.eco;
      case 'Кролики':
        return Icons.pets;
      default:
        return Icons.pets;
    }
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryBright),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none),
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
          builder: (ctx, child) {
            return Theme(
              data: Theme.of(ctx).copyWith(
                colorScheme:
                    const ColorScheme.light(primary: AppColors.primaryBright),
              ),
              child: child!,
            );
          },
        );
        if (picked != null && mounted) setState(() => _birthDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary, width: 1.5),
            borderRadius: BorderRadius.circular(20),
            color: AppColors.background),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: AppColors.primaryBright, size: 20),
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
                    fontSize: 14)),
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
        onPressed: _savePet,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        child: const Text('Сохранить питомца'),
      ),
    );
  }

  void _savePet() {
    if (_nameController.text.isEmpty || _birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Заполните обязательные поля'),
          backgroundColor: AppColors.error));
      return;
    }
    final years =
        ((DateTime.now().difference(_birthDate!).inDays) / 365).floor();
    final ageStr = '$years ${years == 1 ? "год" : years < 5 ? "года" : "лет"}';

    widget.ref.read(homeProvider.notifier).addPet({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': _nameController.text.trim(),
      'breed': _breedController.text.trim().isEmpty
          ? null
          : _breedController.text.trim(),
      'age': ageStr,
      'location': 'Москва',
      'imagePath': _imagePath,
      'category': _selectedCat,
    });

    Navigator.pop(context);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${_nameController.text.trim()} добавлен!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating));
    }
  }
}

class _AppointmentForm extends ConsumerStatefulWidget {
  final AppointmentType type;
  final String title;
  const _AppointmentForm({required this.type, required this.title});
  @override
  ConsumerState<_AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends ConsumerState<_AppointmentForm> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedPetId;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pets = ref.read(homeProvider).pets;
    if (_selectedPetId == null && pets.isNotEmpty) {
      final firstPetId = pets.first['id'] as String?;
      if (firstPetId != null && mounted) {
        setState(() => _selectedPetId = firstPetId);
      }
    }
  }

  Color _getTypeColor() {
    switch (widget.type) {
      case AppointmentType.clinic:
        return AppColors.success;
      case AppointmentType.grooming:
        return AppColors.info;
      case AppointmentType.vaccination:
        return AppColors.secondary;
      case AppointmentType.other:
        return AppColors.warning;
    }
  }

  String _getPawForType(AppointmentType type) {
    switch (type) {
      case AppointmentType.clinic:
        return 'green_paw';
      case AppointmentType.grooming:
        return 'blue_paw';
      case AppointmentType.vaccination:
        return 'blue_paw';
      case AppointmentType.other:
        return 'paw_yellow';
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final pets = homeState.pets;

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFormHeader(widget.title),
          const SizedBox(height: 24),
          _buildPetSelector(pets),
          const SizedBox(height: 16),
          _buildDatePicker(),
          const SizedBox(height: 16),
          _buildTimePicker(),
          const SizedBox(height: 16),
          _buildNotesField(),
          const SizedBox(height: 24),
          _buildSaveButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFormHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _getTypeColor())),
        IconButton(
            icon: const Icon(Icons.close, color: AppColors.textGrey),
            onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _buildPetSelector(List<Map<String, dynamic>> pets) {
    if (pets.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
        child: const Row(children: [
          Icon(Icons.pets_outlined, color: AppColors.textGrey),
          SizedBox(width: 8),
          Text('Сначала добавьте питомца',
              style: TextStyle(color: AppColors.textGrey))
        ]),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Питомец',
            style: TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPetId,
              isExpanded: true,
              hint: const Text('Выберите питомца'),
              key: ValueKey(pets.length),
              items: pets
                  .map((pet) {
                    final petId = pet['id'] as String?;
                    final petName = pet['name'] as String? ?? 'Без имени';

                    if (petId == null) return null;

                    return DropdownMenuItem<String>(
                      value: petId,
                      child: Row(children: [
                        const Icon(Icons.pets,
                            size: 16, color: AppColors.primaryBright),
                        const SizedBox(width: 8),
                        Text(petName)
                      ]),
                    );
                  })
                  .whereType<DropdownMenuItem<String>>()
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedPetId = value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (ctx, child) {
            return Theme(
              data: Theme.of(ctx).copyWith(
                colorScheme: ColorScheme.light(primary: _getTypeColor()),
              ),
              child: child!,
            );
          },
        );
        if (picked != null && mounted) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            border: Border.all(color: _getTypeColor(), width: 1.5),
            borderRadius: BorderRadius.circular(20),
            color: AppColors.background),
        child: Row(children: [
          Icon(Icons.calendar_today_outlined, color: _getTypeColor(), size: 20),
          const SizedBox(width: 8),
          Text(
              '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
              style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                  fontSize: 14)),
        ]),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
          builder: (ctx, child) {
            return Theme(
              data: Theme.of(ctx).copyWith(
                colorScheme: ColorScheme.light(primary: _getTypeColor()),
              ),
              child: child!,
            );
          },
        );
        if (picked != null && mounted) setState(() => _selectedTime = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            border: Border.all(color: _getTypeColor(), width: 1.5),
            borderRadius: BorderRadius.circular(20),
            color: AppColors.background),
        child: Row(children: [
          Icon(Icons.access_time_outlined, color: _getTypeColor(), size: 20),
          const SizedBox(width: 8),
          Text(_selectedTime.format(context),
              style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                  fontSize: 14)),
        ]),
      ),
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Заметки (опционально)',
            style: TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Дополнительная информация...',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveAppointment,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getTypeColor(),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        child: Text('Записать на ${widget.title.toLowerCase()}'),
      ),
    );
  }

  void _saveAppointment() {
    if (_selectedPetId == null || _selectedPetId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Выберите питомца'), backgroundColor: AppColors.error));
      return;
    }

    ref.read(calendarProvider.notifier).addTask(
          _selectedDate,
          widget.title,
          _getPawForType(widget.type),
        );

    if (!mounted) return;
    Navigator.pop(context);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${widget.title}: запись создана!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating));
    }
  }
}
