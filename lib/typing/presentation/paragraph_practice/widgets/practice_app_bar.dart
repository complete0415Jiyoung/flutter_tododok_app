// lib/typing/presentation/paragraph_practice/widgets/practice_app_bar.dart
import 'package:flutter/material.dart';
import '../../../../shared/styles/app_colors_style.dart';
import '../../../../shared/styles/app_text_style.dart';

class PracticeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBackPressed;

  const PracticeAppBar({super.key, required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColorsStyle.white,
      elevation: 0,
      title: Text(
        '장문 연습',
        style: AppTextStyle.heading3.copyWith(
          color: AppColorsStyle.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: AppColorsStyle.textPrimary,
          size: 20,
        ),
        onPressed: onBackPressed,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColorsStyle.border.withOpacity(0.1),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
