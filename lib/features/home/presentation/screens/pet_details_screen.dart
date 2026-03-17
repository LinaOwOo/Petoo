import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:peto/core/theme/app_colors.dart';
import 'package:peto/core/widgets/bottom_nav.dart';
import 'package:peto/features/home/presentation/providers/pet_details_provider.dart';

class PetDetailsScreen extends ConsumerWidget {
  final String petId;
  const PetDetailsScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petState = ref.watch(petDetailsProvider(petId));
    final pet = petState.pet;

    if (pet.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryBright),
            onPressed: () => context.go('/home'),
          ),
          title: const Text('Питомец не найден',
              style: TextStyle(color: AppColors.primaryBright)),
        ),
        body: const Center(
          child: Text('Питомец не найден',
              style: TextStyle(color: AppColors.textGrey)),
        ),
        bottomNavigationBar: const BottomNav(currentIndex: 0),
      );
    }

    final imagePath = pet['imagePath'] as String?;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBright),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          pet['name'] as String? ?? 'Питомец',
          style: const TextStyle(
              color: AppColors.primaryBright, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
            Text(
              '${pet['breed'] as String? ?? 'Порода не указана'} • ${pet['age'] as String? ?? '—'}',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              pet['location'] as String? ?? '—',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: AppColors.textGrey),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showEditModal(context, ref, petId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Редактировать'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
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

  void _showEditModal(BuildContext context, WidgetRef ref, String petId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _EditPetForm(petId: petId),
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

class _EditPetForm extends ConsumerStatefulWidget {
  final String petId;
  const _EditPetForm({required this.petId});

  @override
  ConsumerState<_EditPetForm> createState() => _EditPetFormState();
}

class _EditPetFormState extends ConsumerState<_EditPetForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _breedController;
  late final TextEditingController _ageController;
  late final TextEditingController _locationController;
  String _selectedCat = 'Кошки';
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    final pet = ref.read(petDetailsProvider(widget.petId)).pet;
    _nameController = TextEditingController(text: pet['name'] as String? ?? '');
    _breedController =
        TextEditingController(text: pet['breed'] as String? ?? '');
    _ageController = TextEditingController(text: pet['age'] as String? ?? '');
    _locationController =
        TextEditingController(text: pet['location'] as String? ?? '');
    _selectedCat = pet['category'] as String? ?? 'Кошки';
    _imagePath = pet['imagePath'] as String?;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _locationController.dispose();
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
          _buildFormHeader(),
          const SizedBox(height: 24),
          _buildPhotoPicker(),
          const SizedBox(height: 24),
          _buildCategorySelector(),
          const SizedBox(height: 16),
          _buildTextField(_nameController, 'Кличка', Icons.pets),
          const SizedBox(height: 16),
          _buildTextField(_breedController, 'Порода', Icons.info),
          const SizedBox(height: 16),
          _buildTextField(_ageController, 'Возраст', Icons.calendar_today),
          const SizedBox(height: 16),
          _buildTextField(_locationController, 'Локация', Icons.location_on),
          const SizedBox(height: 24),
          _buildSaveButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFormHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Редактировать питомца',
            style: TextStyle(
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
                ],
              )
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        child: const Text('Сохранить изменения'),
      ),
    );
  }

  void _saveChanges() {
    final notifier = ref.read(petDetailsProvider(widget.petId).notifier);

    notifier.updateField('name', _nameController.text.trim());
    notifier.updateField('breed', _breedController.text.trim());
    notifier.updateField('age', _ageController.text.trim());
    notifier.updateField('location', _locationController.text.trim());
    notifier.updateField('category', _selectedCat);
    if (_imagePath != null) notifier.updateField('imagePath', _imagePath);

    notifier.save();

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Изменения сохранены'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating),
    );
  }
}

// class _StatCircle extends StatelessWidget {
//   final String value;
//   final String label;
//   final Color borderColor;

//   const _StatCircle(this.value, this.label,
//       {this.borderColor = AppColors.primaryBright});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           width: 80,
//           height: 80,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(color: borderColor, width: 6),
//           ),
//           alignment: Alignment.center,
//           child: Text(
//             value,
//             style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textDark),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(label,
//             style: Theme.of(context)
//                 .textTheme
//                 .labelMedium
//                 ?.copyWith(color: AppColors.textGrey)),
//       ],
//     );
//   }
// }
