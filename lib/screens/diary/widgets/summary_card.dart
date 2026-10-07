import 'package:flutter/material.dart';
import '../../../theme/theme.dart';
import '../../../models/enums.dart';
import '../../../models/diary_entry.dart';

class SummaryCard extends StatelessWidget {
  final List<DiaryEntry> entries;
  final DateTime bulan;

  const SummaryCard({
    super.key,
    required this.entries,
    required this.bulan,
  });

  int get _totalEntry => entries.length;

  int get _hariGlowing => entries
      .where((e) => e.kondisiUtama == KondisiKulit.glowing)
      .length;

  int get _hariBreakout => entries
      .where((e) => e.kondisiUtama == KondisiKulit.berjerawat)
      .length;

  int get _hariIritasi => entries
      .where((e) => e.kondisiUtama == KondisiKulit.iritasi)
      .length;

  double get _rataIntensitas {
    if (entries.isEmpty) return 0;
    final total = entries.fold<int>(0, (sum, e) => sum + e.intensitas);
    return total / entries.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Bulan Ini',
            style: AppText.cardTitle.copyWith(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _statItem(
                  icon: Icons.calendar_today_outlined,
                  value: '$_totalEntry',
                  label: 'Hari Tercatat',
                ),
              ),
              Expanded(
                child: _statItem(
                  icon: Icons.auto_awesome_outlined,
                  value: '$_hariGlowing',
                  label: 'Hari Glowing',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _statItem(
                  icon: Icons.warning_amber_outlined,
                  value: '$_hariBreakout',
                  label: 'Breakout',
                ),
              ),
              Expanded(
                child: _statItem(
                  icon: Icons.local_fire_department_outlined,
                  value: '$_hariIritasi',
                  label: 'Iritasi',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.trending_up,
                size: 18,
                color: AppColors.accent,
              ),
              const SizedBox(width: 8),
              Text(
                'Rata-rata intensitas: ',
                style: AppText.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              Text(
                '${_rataIntensitas.toStringAsFixed(0)}%',
                style: AppText.bodySmall.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: AppColors.accent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppText.cardTitle.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              Text(
                label,
                style: AppText.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}