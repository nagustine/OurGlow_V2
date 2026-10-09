import 'package:flutter/material.dart';
import '../../../theme/theme.dart';
import '../../../models/enums.dart';
import '../../../models/routine_product.dart';

class ConflictWarning extends StatelessWidget {
  final List<RoutineProduct> products;

  const ConflictWarning({super.key, required this.products});

  List<String> _detectConflicts() {
    final warnings = <String>[];
    final ids = products.map((p) => p.id).toSet().toList();

    for (var i = 0; i < ids.length; i++) {
      for (var j = i + 1; j < ids.length; j++) {
        final a = products.firstWhere((p) => p.id == ids[i]);
        final b = products.firstWhere((p) => p.id == ids[j]);

        // Skip kalau beda waktu pakai
        if (a.waktuPakai != b.waktuPakai &&
            a.waktuPakai != WaktuPakai.pagiDanMalam &&
            b.waktuPakai != WaktuPakai.pagiDanMalam) {
          continue;
        }

        // Cek konflik berdasarkan nama bahan
        for (final ba in a.bahan) {
          if (b.bahan.any((bb) => bb.toLowerCase() == ba.toLowerCase())) {
            warnings.add(
              '${a.nama} + ${b.nama}: mengandung bahan yang sama ($ba)',
            );
          }
        }
      }
    }

    return warnings;
  }

  @override
  Widget build(BuildContext context) {
    final conflicts = _detectConflicts();

    if (conflicts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.statusSafe.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.statusSafe.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.statusSafe,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tidak ada konflik',
                    style: AppText.cardTitle.copyWith(
                      fontSize: 14,
                      color: AppColors.statusSafe,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rutinitas kamu sudah aman',
                    style: AppText.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.statusWarning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.statusWarning.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.statusWarning,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${conflicts.length} konflik terdeteksi',
                  style: AppText.cardTitle.copyWith(
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...conflicts.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(
                      c,
                      style: AppText.bodySmall.copyWith(
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}