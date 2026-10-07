import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../services/service_locator.dart';
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
      Navigator.popUntil(context, (route) => route.isFirst);
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => target),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    if (isMobile || isTablet) {
      return Container(
        height: 56,
        color: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: InkWell(
                onTap: () => _goTo(context, 'Beranda'),
                borderRadius: BorderRadius.circular(AppRadius.small),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            Image.asset(
              AppAssets.logo,
              height: 32,
              errorBuilder: (_, __, ___) => const SizedBox(height: 32),
            ),
            const Spacer(),
            _buildProfileButton(context),
          ],
        ),
      );
    }

    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _goTo(context, 'Beranda'),
            child: Image.asset(
              AppAssets.logo,
              width: 54,
              height: 54,
              errorBuilder: (_, __, ___) => const SizedBox(
                width: 54,
                height: 54,
              ),
            ),
          ),
          const Spacer(),
          _navItem(context, 'Beranda'),
          _navItem(context, 'Scan Produk'),
          _navItem(context, 'Routine Checker'),
          _navItem(context, 'Skin Diary'),
          const SizedBox(width: 8),
          _buildProfileButton(context),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, String label) {
    final active = label == activeMenu;
    return InkWell(
      onTap: () => _goTo(context, label),
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: Container(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppText.body.copyWith(
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

  Widget _buildProfileButton(BuildContext context) {
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.accent, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
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
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Profil',
                style: AppText.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginRegisterScreen(),
          ),
        );
      },
      icon: const Icon(Icons.login, size: 16),
      label: const Text('Login'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: const StadiumBorder(),
        textStyle: AppText.buttonLabel.copyWith(fontSize: 13),
      ),
    );
  }
}