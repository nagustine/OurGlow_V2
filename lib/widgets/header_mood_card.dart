import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../models/enums.dart';

class HeaderMoodCard extends StatelessWidget {
  final List<KondisiKulit> conditions;
  final DateTime? tanggal;

  const HeaderMoodCard({
    super.key,
    required this.conditions,
    this.tanggal,
  });

  String _formatTanggal(DateTime? t) {
    if (t == null) return '';
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${t.day} ${bulan[t.month - 1]} ${t.year}';
  }

  @override
  Widget build(BuildContext context) {
    final primary = conditions.isEmpty
        ? SkinConditionStyles.fallback
        : SkinConditionStyles.byKey(conditions.first.name);

    final isDark = primary.color.computeLuminance() < 0.5;
    final fgColor = isDark ? Colors.white : AppColors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: primary.color,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              primary.emoji,
              style: const TextStyle(fontSize: 36),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tanggal != null) ...[
                  Text(
                    _formatTanggal(tanggal),
                    style: AppText.caption.copyWith(
                      color: fgColor.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  primary.label,
                  style: AppText.sectionTitle.copyWith(
                    fontSize: 20,
                    color: fgColor,
                  ),
                ),
                const SizedBox(height: 4),
                if (conditions.length > 1)
                  Text(
                    '+ ${conditions.length - 1} kondisi lain',
                    style: AppText.bodySmall.copyWith(
                      color: fgColor.withValues(alpha: 0.85),
                    ),
                  )
                else
                  Text(
                    'Kondisi kulit hari ini',
                    style: AppText.bodySmall.copyWith(
                      color: fgColor.withValues(alpha: 0.85),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}