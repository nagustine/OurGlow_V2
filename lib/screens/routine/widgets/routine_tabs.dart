import 'package:flutter/material.dart';
import '../../../theme/theme.dart';
import '../../../models/enums.dart';

class RoutineTabs extends StatelessWidget {
  final WaktuPakai activeTab;
  final ValueChanged<WaktuPakai> onTabChanged;
  final int pagiCount;
  final int malamCount;

  const RoutineTabs({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
    required this.pagiCount,
    required this.malamCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tabItem(
              label: 'Pagi',
              icon: Icons.wb_sunny_outlined,
              waktu: WaktuPakai.pagi,
              count: pagiCount,
            ),
          ),
          Expanded(
            child: _tabItem(
              label: 'Malam',
              icon: Icons.nights_stay_outlined,
              waktu: WaktuPakai.malam,
              count: malamCount,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabItem({
    required String label,
    required IconData icon,
    required WaktuPakai waktu,
    required int count,
  }) {
    final active = activeTab == waktu;
    return GestureDetector(
      onTap: () => onTabChanged(waktu),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppText.badge.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.accent
                    : AppColors.accent.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                '$count',
                style: AppText.caption.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}