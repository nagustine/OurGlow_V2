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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    if (isMobile || isTablet) {
      return _buildMobileNavbar(context);
    }

    return _buildDesktopNavbar(context);
  }

  // ═══════════════════════════════════════════
  // MOBILE NAVBAR
  // ═══════════════════════════════════════════
  Widget _buildMobileNavbar(BuildContext context) {
    return Container(
      height: 56,
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          // Tombol Garis 3 (Hamburger)
          SizedBox(
            width: 48,
            height: 48,
            child: Builder(
              builder: (ctx) => IconButton(
                onPressed: () {
                  final scaffold = Scaffold.maybeOf(ctx);
                  if (scaffold != null && scaffold.hasDrawer) {
                    scaffold.openDrawer();
                  }
                },
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 24,
                ),
                splashRadius: 24,
              ),
            ),
          ),

          // Logo
          GestureDetector(
            onTap: () => _goTo(context, 'Beranda'),
            child: Image.asset(
              AppAssets.logo,
              height: 32,
              errorBuilder: (_, __, ___) => const SizedBox(height: 32),
            ),
          ),

          const Spacer(),

          // Tombol Login / Profil
          _buildMobileActionButton(context),
        ],
      ),
    );
  }

  Widget _buildMobileActionButton(BuildContext context) {
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
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  user?.nama.isNotEmpty == true
                      ? user!.nama[0].toUpperCase()
                      : '?',
                  style: AppText.badge.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Profil',
                style: AppText.buttonLabel.copyWith(
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: ElevatedButton(
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const StadiumBorder(),
        ),
        child: Text(
          'Login',
          style: AppText.buttonLabel.copyWith(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // DESKTOP NAVBAR
  // ═══════════════════════════════════════════
  Widget _buildDesktopNavbar(BuildContext context) {
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
          _buildDesktopActionButton(context),
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

  Widget _buildDesktopActionButton(BuildContext context) {
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
        MaterialPageRoute(builder: (_) => const LoginRegisterScreen()),
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
}

// ═══════════════════════════════════════════
// APP DRAWER
// ═══════════════════════════════════════════
class AppDrawer extends StatelessWidget {
  final String activeMenu;

  const AppDrawer({super.key, required this.activeMenu});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFFF2F2),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Drawer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menu utama',
                    style: AppText.sectionTitle.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'OurGlow Skincare Checker',
                    style: AppText.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            _drawerItem(context, 'Beranda', Icons.home_outlined),
            _drawerItem(context, 'Scan Produk', Icons.camera_alt_outlined),
            _drawerItem(context, 'Routine Checker', Icons.checklist_outlined),
            _drawerItem(context, 'Skin Diary', Icons.book_outlined),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, String label, IconData icon) {
    final active = label == activeMenu;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          _navigate(context, label);
        },
        borderRadius: BorderRadius.circular(AppRadius.small),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: active
                ? AppColors.accent.withValues(alpha: 0.25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: const Color(0xFF600018),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: AppText.body.copyWith(
                  fontSize: 16,
                  color: const Color(0xFF600018),
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String menu) {
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
        MaterialPageRoute(builder: (_) => const LoginRegisterScreen()),
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
}