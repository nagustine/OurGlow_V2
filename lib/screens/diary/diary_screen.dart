import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../models/enums_ext.dart';
import '../../models/diary_entry.dart';
import '../../services/service_locator.dart';
import '../../widgets/app_navbar.dart';
import '../../widgets/loading_overlay.dart';
import 'widgets/calendar_card.dart';
import 'widgets/summary_card.dart';
import 'widgets/diary_form_card.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  late DateTime _selectedDate;
  List<DiaryEntry> _entries = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ServiceLocator.diary.getAll();
      if (!mounted) return;
      setState(() {
        _entries = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DiaryEntry? get _entryForSelectedDate {
    for (final e in _entries) {
      if (_sameDay(e.tanggal, _selectedDate)) return e;
    }
    return null;
  }

  List<DiaryEntry> get _entriesThisMonth {
    return _entries
        .where((e) =>
            e.tanggal.year == _selectedDate.year &&
            e.tanggal.month == _selectedDate.month)
        .toList()
      ..sort((a, b) => a.tanggal.compareTo(b.tanggal));
  }

  Set<DateTime> get _markedDates {
    return _entries
        .map((e) => DateTime(e.tanggal.year, e.tanggal.month, e.tanggal.day))
        .toSet();
  }

  Future<void> _handleSave(DiaryEntry entry) async {
    final existing = _entryForSelectedDate;

    try {
      if (existing != null) {
        await ServiceLocator.diary.update(entry);
        if (!mounted) return;
        setState(() {
          final idx = _entries.indexWhere((e) => e.id == existing.id);
          if (idx != -1) _entries[idx] = entry;
        });
      } else {
        await ServiceLocator.diary.add(entry);
        if (!mounted) return;
        setState(() => _entries.add(entry));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing != null
                ? 'Catatan berhasil diperbarui'
                : 'Catatan berhasil disimpan',
          ),
          backgroundColor: AppColors.statusSafe,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: ${e.toString()}'),
          backgroundColor: AppColors.statusDanger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;
    final hPad = isDesktop ? 60.0 : 16.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LoadingOverlay(
        isLoading: _loading,
        child: Column(
          children: [
            const AppNavbar(activeMenu: 'Skin Diary'),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadEntries,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: hPad,
                          vertical: 16,
                        ),
                        child: _error != null
                            ? _buildError()
                            : Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  if (isDesktop)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: CalendarCard(
                                            selectedDate: _selectedDate,
                                            onDateSelected: (d) =>
                                                setState(() =>
                                                    _selectedDate = d),
                                            markedDates: _markedDates,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: SummaryCard(
                                            entries: _entriesThisMonth,
                                            bulan: _selectedDate,
                                          ),
                                        ),
                                      ],
                                    )
                                  else ...[
                                    CalendarCard(
                                      selectedDate: _selectedDate,
                                      onDateSelected: (d) => setState(
                                          () => _selectedDate = d),
                                      markedDates: _markedDates,
                                    ),
                                    const SizedBox(height: 16),
                                    SummaryCard(
                                      entries: _entriesThisMonth,
                                      bulan: _selectedDate,
                                    ),
                                  ],
                                  const SizedBox(height: 24),
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(28),
                                      border: Border.all(
                                        color: AppColors.accent,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.08),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: DiaryFormCard(
                                      key: ValueKey(
                                        _selectedDate
                                            .toIso8601String(),
                                      ),
                                      tanggal: _selectedDate,
                                      initial: _entryForSelectedDate,
                                      onSave: _handleSave,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildRiwayat(),
                                ],
                              ),
                      ),
                      const SizedBox(height: 24),
                      // Copyright full width + ikut scroll
                      const _CopyrightBar(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayat() {
    if (_entries.isEmpty) {
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
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada riwayat',
              style: AppText.cardTitle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Mulai catat kondisi kulitmu hari ini',
              textAlign: TextAlign.center,
              style: AppText.caption,
            ),
          ],
        ),
      );
    }

    final sorted = List<DiaryEntry>.from(_entries)
      ..sort((a, b) => b.tanggal.compareTo(a.tanggal));

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
          Row(
            children: [
              const Icon(
                Icons.history,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Riwayat Terbaru',
                style: AppText.cardTitle.copyWith(fontSize: 16),
              ),
              const Spacer(),
              Text('${sorted.length} catatan', style: AppText.caption),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...sorted.take(5).map((e) => _buildRiwayatItem(e)),
        ],
      ),
    );
  }

  Widget _buildRiwayatItem(DiaryEntry e) {
    final isSelected = _sameDay(e.tanggal, _selectedDate);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => setState(() => _selectedDate = e.tanggal),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accent.withValues(alpha: 0.2)
                : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.accent
                  : AppColors.primary.withValues(alpha: 0.08),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${e.tanggal.day}',
                      style: AppText.cardTitle.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      e.hariLabel,
                      style: AppText.caption.copyWith(
                        fontSize: 9,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.kondisiUtama.label,
                      style: AppText.body.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (e.masalah.isNotEmpty)
                      Text(
                        e.masalah.join(', '),
                        style: AppText.caption.copyWith(fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (e.hasCatatan) ...[
                      const SizedBox(height: 4),
                      Text(
                        e.catatan,
                        style: AppText.bodySmall.copyWith(
                          fontSize: 11,
                          height: 1.4,
                          color: AppColors.textDark.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.statusDanger.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data',
              style: AppText.cardTitle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: AppText.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadEntries,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CopyrightBar extends StatelessWidget {
  const _CopyrightBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          Text(
            '© 2026 OurGlow — Skincare Checker',
            textAlign: TextAlign.center,
            style: AppText.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dea Apriani Agustin',
            textAlign: TextAlign.center,
            style: AppText.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}