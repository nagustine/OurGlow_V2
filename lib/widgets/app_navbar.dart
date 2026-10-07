import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../services/service_locator.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/login_register_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/scan/scan_screen.dart';
import '../screens/routine/routine_screen.dart';
import '../screens/diary/diary_screen.dart';

class AppNavbar extends StatelessWidget {
  final String activeMenu;

  const AppNavbar({super.key, required this.activeMenu});

  bool get _isLoggedIn => ServiceLocator.auth.currentUser != null;

  void _goTo(BuildContext context, String menu) {
    if (menu == activeMenu) return;

    final isLoggedIn = ServiceLocator.auth.currentUser != null;

    if (menu == 'Beranda') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
      return;
    }

    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login dulu untuk mengakses fitur ini'),
          backgroundColor: AppColors.statusWarning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginRegisterScreen(),
        ),
      );
      return;
    }

    Widget target;
    switch (menu) {
      case 'Scan Produk':
        target = const ScanScreen();
        break;
      case 'Routine Checker':
        target = const RoutineScreen();
        break;
      case 'Skin Diary':
        target = const DiaryScreen();
        break;
      default:
        return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => target),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    // Ukuran responsif
    final logoSize = isMobile ? 36.0 : (isTablet ? 44.0 : 54.0);
    final fontSize = isMobile ? 11.0 : (isTablet ? 12.0 : 14.0);
    final hPad = isMobile ? 8.0 : (isTablet ? 16.0 : 24.0);
    final itemPadH = isMobile ? 6.0 : 12.0;
    final itemPadV = isMobile ? 8.0 : 12.0;

    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.symmetric(
        horizontal: hPad,
        vertical: isMobile ? 8 : 12,
      ),
      child: Row(
        children: [
          // Logo
          GestureDetector(
            onTap: () => _goTo(context, 'Beranda'),
            child: Image.asset(
              AppAssets.logo,
              width: logoSize,
              height: logoSize,
              errorBuilder: (_, __, ___) => SizedBox(
                width: logoSize,
                height: logoSize,
              ),
            ),
          ),
          const Spacer(),

          // Menu items
          _navItem(context, 'Beranda', isMobile, fontSize, itemPadH, itemPadV),
          _navItem(context, 'Scan Produk', isMobile, fontSize, itemPadH, itemPadV),
          _navItem(context, 'Routine Checker', isMobile, fontSize, itemPadH, itemPadV),
          _navItem(context, 'Skin Diary', isMobile, fontSize, itemPadH, itemPadV),

          SizedBox(width: isMobile ? 4 : 8),
          _buildProfileButton(context, isMobile, fontSize),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    String label,
    bool isMobile,
    double fontSize,
    double padH,
    double padV,
  ) {
    final active = label == activeMenu;
    return InkWell(
      onTap: () => _goTo(context, label),
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: Container(
        constraints: BoxConstraints(
          minWidth: isMobile ? 0 : 48,
          minHeight: isMobile ? 36 : 48,
        ),
        padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppText.body.copyWith(
            fontSize: fontSize,
            color: active
                ? AppColors.accent
                : Colors.white.withValues(alpha: 0.85),
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            decoration:
                active ? TextDecoration.underline : TextDecoration.none,
            decorationColor: AppColors.accent,
            decorationThickness: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton(
    BuildContext context,
    bool isMobile,
    double fontSize,
  ) {
    if (_isLoggedIn) {
      final user = ServiceLocator.auth.currentUser;
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        },
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 6 : 12,
            vertical: isMobile ? 4 : 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.accent, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: isMobile ? 20 : 28,
                height: isMobile ? 20 : 28,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  user?.nama.isNotEmpty == true
                      ? user!.nama[0].toUpperCase()
                      : '?',
                  style: AppText.badge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: isMobile ? 10 : 12,
                  ),
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 8),
                Text(
                  'Profil',
                  style: AppText.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: fontSize,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginRegisterScreen(),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 16,
          vertical: isMobile ? 6 : 10,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const StadiumBorder(),
      ),
      child: Text(
        'Login',
        style: AppText.buttonLabel.copyWith(
          fontSize: isMobile ? 11 : 13,
        ),
      ),
    );
  }
}