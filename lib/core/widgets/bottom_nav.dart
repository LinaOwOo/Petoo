import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:peto/core/theme/app_colors.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int)? onItemSelected;

  const BottomNav({
    super.key,
    required this.currentIndex,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    const navItems = [
      {'icon': 'assets/icons/home.svg', 'route': '/home'},
      {'icon': 'assets/icons/target.svg', 'route': '/care-tracker'},
      {'icon': 'assets/icons/calendar.svg', 'route': '/calendar'},
      {'icon': 'assets/icons/profile.svg', 'route': '/profile'},
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
        children: List.generate(4, (index) {
          final isActive = index == currentIndex;

          return GestureDetector(
            // ✅ ВАЖНО: HitTestBehavior.opaque для надёжного тапа
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (index != currentIndex) {
                // ✅ GoRouter навигация
                context.go(navItems[index]['route']!);
              }
            },
            child: SvgPicture.asset(
              navItems[index]['icon']!,
              width: 28,
              height: 28,
              colorFilter: ColorFilter.mode(
                isActive ? AppColors.primaryBright : AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
          );
        }),
      ),
    );
  }
}
