import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../services/service_locator.dart';
import '../screens/auth/login_register_screen.dart';
import '../screens/profile/profile_screen.dart';

class BackNavbar extends StatelessWidget {
  final String title;

  const BackNavbar({
    super.key,
    required this.title,
  });

  bool get _isLoggedIn => ServiceLocator.auth.currentUser != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          // Tombol Back Panah
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 22,
              ),
              splashRadius: 24,
              tooltip: 'Kembali',
            ),
          ),

          const SizedBox(width: 8),

          // Title
          Expanded(
            child: Text(
              title,
              style: AppText.sectionTitle.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Tombol Login / Profil
          _buildActionButton(context),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
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
}