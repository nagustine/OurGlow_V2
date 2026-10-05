import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

class CalendarCard extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final Set<DateTime> markedDates;

  const CalendarCard({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.markedDates = const {},
  });

  static const List<String> _bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  static const List<String> _hariPendek = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    final daysInMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    final startWeekday = firstDay.weekday; // 1 = Senin, 7 = Minggu

    // Grid: berapa sel kosong sebelum tanggal 1
    final leadingEmpty = startWeekday - 1;
    final totalCells = leadingEmpty + daysInMonth;
    final totalRows = (totalCells / 7).ceil();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Bulan & Tahun + tombol navigasi
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_bulan[selectedDate.month - 1]} ${selectedDate.year}',
                  style: AppText.cardTitle.copyWith(fontSize: 16),
                ),
              ),
              _navButton(
                Icons.chevron_left,
                () {
                  final prev = DateTime(
                    selectedDate.year,
                    selectedDate.month - 1,
                    1,
                  );
                  onDateSelected(prev);
                },
              ),
              const SizedBox(width: 4),
              _navButton(
                Icons.chevron_right,
                () {
                  final next = DateTime(
                    selectedDate.year,
                    selectedDate.month + 1,
                    1,
                  );
                  onDateSelected(next);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Header hari (Sen, Sel, Rab, ...)
          Row(
            children: _hariPendek
                .map(
                  (h) => Expanded(
                    child: Center(
                      child: Text(
                        h,
                        style: AppText.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Grid tanggal
          ...List.generate(totalRows, (row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: List.generate(7, (col) {
                  final cellIndex = row * 7 + col;
                  final dayNumber = cellIndex - leadingEmpty + 1;

                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const Expanded(child: SizedBox(height: 36));
                  }

                  final date = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    dayNumber,
                  );
                  final isSelected = _sameDay(date, selectedDate);
                  final isToday = _sameDay(date, DateTime.now());
                  final isMarked = markedDates.any((d) => _sameDay(d, date));

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onDateSelected(date),
                      child: Container(
                        height: 36,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : isToday
                                  ? AppColors.accent.withValues(alpha: 0.25)
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                          border: isToday && !isSelected
                              ? Border.all(
                                  color: AppColors.accent,
                                  width: 1.5,
                                )
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '$dayNumber',
                              style: AppText.bodySmall.copyWith(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textDark,
                              ),
                            ),
                            if (isMarked && !isSelected)
                              Positioned(
                                bottom: 4,
                                child: Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
    );
  }
}