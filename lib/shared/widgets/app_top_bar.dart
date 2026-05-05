import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBack;

  const AppTopBar({super.key, this.title, this.showBack = true});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      leading: showBack
          ? IconButton(
              icon: Image.asset(
                'assets/UI icons package/PNG/Black/Arrow/Arrow_Left_MD.png',
                width: 24,
                height: 24,
                color: AppColors.secondary,
              ),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      automaticallyImplyLeading: false,
      title: title == null
          ? null
          : Text(
              title!,
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                color: AppColors.secondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
      centerTitle: true,
    );
  }
}
