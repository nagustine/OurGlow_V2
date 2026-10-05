import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../data/mock_diary.dart';
import '../../models/diary_entry.dart';
import '../../models/enums.dart';
import '../../models/enums_ext.dart';
import '../../services/service_locator.dart';
import 'widgets/calendar_card.dart';
import 'widgets/summary_card.dart';
import 'widgets/daily_form_card.dart';

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

  Future<void> _handleSave({
    required List<KondisiKulit> kondisi,
    required int intensitas,
    required List<dynamic> produk,
    required String catatan,
  }) async {
    final existing = _entryForSelectedDate;

    try {
      if (existing != null) {
        final updated = existing.copyWith(
          kondisiKulit: kondisi,
          intensitas: intensitas,
          produkDipakai: produk.cast(),
          catatan: catatan,
        );
        await ServiceLocator.diary.update(updated);
        if (!mounted) return;
        setState(() {
          final idx = _entries.indexWhere((e) => e.id == existing.id);
          if (idx != -1) _entries[idx] = updated;
        });
      } else {
        final newEntry = DiaryEntry(
          id: 'diary_${_selectedDate.millisecondsSinceEpoch}',
          tanggal: _selectedDate,
          kondisiKulit: kondisi,
          intensitas: intensitas,
          produkDipakai: produk.cast(),
          catatan: catatan,
          statusRutin: StatusAman.aman,
        );
        await ServiceLocator.diary.add(newEntry);
        if (!mounted) return;
        setState(() => _entries.add(newEntry));
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Skin Diary'),
        actions: [
          IconButton(
            onPressed: _loadEntries,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 60 : 16,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ===== ATAS: Kalender + Ringkasan =====
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: CalendarCard(
                                selectedDate: _selectedDate,
                                onDateSelected: (d) =>
                                    setState(() => _selectedDate = d),
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
                          onDateSelected: (d) =>
                              setState(() => _selectedDate = d),
                          markedDates: _markedDates,
                        ),
                        const SizedBox(height: 16),
                        SummaryCard(
                          entries: _entriesThisMonth,
                          bulan: _selectedDate,
                        ),
                      ],

                      const SizedBox(height: 24),

                      // ===== TENGAH: Form Input =====
                      DailyFormCard(
                        key: ValueKey(_selectedDate.toIso8601String()),
                        tanggal: _selectedDate,
                        initialKondisi:
                            _entryForSelectedDate?.kondisiKulit ?? const [],
                        initialIntensitas:
                            _entryForSelectedDate?.intensitas ?? 50,
                        initialProduk:
                            _entryForSelectedDate?.produkDipakai ?? const [],
                        initialCatatan:
                            _entryForSelectedDate?.catatan ?? '',
                        produkTersedia: MockDiary.produkTersedia,
                        onSave: _handleSave,
                      ),

                      const SizedBox(height: 24),

                      // ===== BAWAH: Riwayat Terbaru =====
                      _buildRiwayatTerbaru(),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildRiwayatTerbaru() {
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
              Text(
                '${sorted.length} catatan',
                style: AppText.caption,
              ),
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
        onTap: () {
          setState(() => _selectedDate = e.tanggal);
        },
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
              // Date Box
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
                    // Kondisi chips
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: e.kondisiKulit.map((k) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            k.label,
                            style: AppText.caption.copyWith(
                              fontSize: 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 6),
                    // Catatan
                    Text(
                      e.catatan.isEmpty ? '(tidak ada catatan)' : e.catatan,
                      style: AppText.bodySmall.copyWith(
                        fontSize: 12,
                        height: 1.4,
                        color: e.catatan.isEmpty
                            ? AppColors.textDark.withValues(alpha: 0.4)
                            : AppColors.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Intensitas
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 12,
                          color: AppColors.primary.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Intensitas ${e.intensitas}%',
                          style: AppText.caption.copyWith(fontSize: 10),
                        ),
                        if (e.produkDipakai.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.spa_outlined,
                            size: 12,
                            color:
                                AppColors.primary.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${e.jumlahProduk} produk',
                            style: AppText.caption.copyWith(fontSize: 10),
                          ),
                        ],
                      ],
                    ),
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
          mainAxisAlignment: MainAxisAlignment.center,
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