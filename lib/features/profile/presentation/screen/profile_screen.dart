import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:peto/core/theme/app_colors.dart';
import 'package:peto/features/home/presentation/screens/home_screen.dart';
import 'package:peto/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:peto/features/care_tracker/presentation/screens/care_tracker_screen.dart';
import 'package:peto/features/home/presentation/providers/home_provider.dart';
import 'package:peto/features/calendar/presentation/providers/calendar_provider.dart';
import 'package:peto/features/profile/presentation/provider/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _navIndex = 3;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final homeState = ref.watch(homeProvider);
    final calendarState = ref.watch(calendarProvider);

    final totalTasks = calendarState.tasks.length;
    final completedTasks =
        calendarState.tasks.where((task) => task['completed'] == true).length;
    final petsCount = homeState.pets.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildProfileHeader(profile),
              Expanded(
                child:
                    _buildProfileContent(totalTasks, completedTasks, petsCount),
              ),
              _buildBottomNavBar(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileState profile) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showEditProfileModal(context),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryBright, width: 2),
              image: profile.avatarPath != null
                  ? DecorationImage(
                      image: FileImage(File(profile.avatarPath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: profile.avatarPath == null
                ? const Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.primaryBright,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          profile.userName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBright,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Owner of ${profile.petName} ${profile.petEmoji}',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileContent(
      int totalTasks, int completedTasks, int petsCount) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem('Tasks', '$totalTasks', AppColors.info),
              _StatItem('Completed', '$completedTasks', AppColors.success),
              _StatItem('Pets', '$petsCount', AppColors.warning),
            ],
          ),
          const SizedBox(height: 40),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showEditProfileModal(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Edit profile',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Log out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
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

    setState(() {
      _navIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CareTrackerScreen()),
        );
        break;
      case 2:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CalendarScreen()),
        );
        break;
      case 3:
        break;
    }
  }

  void _showEditProfileModal(BuildContext context) {
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _EditProfileForm(ref: ref),
    );
  }
}

class _EditProfileForm extends StatefulWidget {
  final WidgetRef ref;
  const _EditProfileForm({required this.ref});

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  final _userNameController = TextEditingController();
  final _petNameController = TextEditingController();
  final _petEmojiController = TextEditingController();
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    final profile = widget.ref.read(profileProvider);
    _userNameController.text = profile.userName;
    _petNameController.text = profile.petName;
    _petEmojiController.text = profile.petEmoji;
    _avatarPath = profile.avatarPath;
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _petNameController.dispose();
    _petEmojiController.dispose();
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
          _buildFormHeader(),
          const SizedBox(height: 24),
          _buildPhotoPicker(),
          const SizedBox(height: 24),
          _buildTextField(_userNameController, 'Имя владельца', Icons.person),
          const SizedBox(height: 16),
          _buildTextField(_petNameController, 'Имя питомца', Icons.pets),
          const SizedBox(height: 16),
          _buildTextField(
              _petEmojiController, 'Стикер (эмодзи)', Icons.emoji_emotions),
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
        const Text(
          'Редактировать профиль',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBright,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.textGrey),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildPhotoPicker() {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final photo = await picker.pickImage(source: ImageSource.gallery);
        if (photo != null && mounted) {
          setState(() => _avatarPath = photo.path);
        }
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: _avatarPath != null ? Colors.transparent : AppColors.info,
          borderRadius: BorderRadius.circular(20),
          image: _avatarPath != null
              ? DecorationImage(
                  image: FileImage(File(_avatarPath!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _avatarPath == null
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

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryBright),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        child: const Text('Сохранить изменения'),
      ),
    );
  }

  void _saveProfile() {
    if (_userNameController.text.isEmpty) return;

    widget.ref.read(profileProvider.notifier).updateProfile(
          userName: _userNameController.text.trim(),
          avatarPath: _avatarPath,
          petName: _petNameController.text.trim(),
          petEmoji: _petEmojiController.text.trim(),
        );

    Navigator.pop(context);
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final Color bgColor;

  const _StatItem(this.title, this.value, this.bgColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
