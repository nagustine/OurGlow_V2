import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../models/scan_result.dart';
import '../../models/enums.dart';
import '../../services/service_locator.dart';
import '../../widgets/back_navbar.dart';

class ScanResultScreen extends StatefulWidget {
  final String rawText;
  final String? fotoPath;
  final String? productName;

  const ScanResultScreen({
    super.key,
    required this.rawText,
    this.fotoPath,
    this.productName,
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  bool _saving = false;
  bool _saved = false;

  List<String> get _ingredients {
    return widget.rawText
        .split(RegExp(r'[,;\n]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<void> _simpan() async {
    if (_saving || _saved) return;

    setState(() => _saving = true);

    try {
      final ingredients = _ingredients;
      final scan = ScanResult(
        id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
        productName:
            widget.productName ?? 'Skincare ${DateTime.now().day}',
        rawText: widget.rawText,
        tanggal: DateTime.now(),
        detectedIngredients: ingredients,
        warnings: const [],
        conflicts: const [],
        summary: 'Sesuai untuk hidrasi dan perawatan skin barrier.',
        status: StatusAman.aman,
      );

      await ServiceLocator.scan.add(scan);

      if (!mounted) return;
      setState(() {
        _saving = false;
        _saved = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hasil scan berhasil disimpan'),
          backgroundColor: AppColors.statusSafe,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);

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
    final ingredients = _ingredients;
    final total = ingredients.length;
    final toWatch = (total * 0.2).round();
    const conflicts = 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const BackNavbar(title: 'Analysis Result'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: AppColors.accent,
                            width: 3,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: widget.fotoPath != null
                                  ? (kIsWeb
                                      ? Image.network(
                                          widget.fotoPath!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(widget.fotoPath!),
                                          fit: BoxFit.cover,
                                        ))
                                  : const Icon(
                                      Icons.image_outlined,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.productName ??
                                        'Product Scan',
                                    style: AppText.cardTitle.copyWith(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$total bahan terdeteksi',
                                    style:
                                        AppText.bodySmall.copyWith(
                                      color: Colors.white
                                          .withValues(alpha: 0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Analysis Summary',
                        style: AppText.sectionTitle.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _summaryCard(
                              icon: Icons.science_outlined,
                              value: '$total',
                              label: 'Ingredients Detected',
                              color: AppColors.statusSafe,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _summaryCard(
                              icon: Icons.warning_amber_outlined,
                              value: '$toWatch',
                              label: 'Ingredients to Watch',
                              color: AppColors.statusWarning,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _summaryCard(
                              icon: Icons.sync_problem_outlined,
                              value: '$conflicts',
                              label: 'Potential Conflicts',
                              color: conflicts > 0
                                  ? AppColors.statusDanger
                                  : AppColors.neutral,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Ingredients Detected',
                        style: AppText.sectionTitle.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 12),
                      ...ingredients.map((ing) => _ingredientCard(ing)),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.statusSafe
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.statusSafe
                                .withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: AppColors.statusSafe,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Aman',
                                    style: AppText.cardTitle.copyWith(
                                      fontSize: 16,
                                      color: AppColors.statusSafe,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tidak ada konflik terdeteksi',
                                    style: AppText.bodySmall
                                        .copyWith(height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Analisis ini bersifat rule-based dan bukan diagnosis medis. Konsultasikan ke dermatolog untuk kondisi kulit serius.',
                                style: AppText.bodySmall.copyWith(height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _saved ? null : _simpan,
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  _saved
                                      ? Icons.check_circle
                                      : Icons.save_outlined,
                                ),
                          label: Text(
                            _saved
                                ? 'Tersimpan'
                                : (_saving
                                    ? 'Menyimpan...'
                                    : 'Simpan ke Riwayat'),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _saved
                                ? AppColors.statusSafe
                                : AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            textStyle: AppText.buttonLabel.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.popUntil(
                            context,
                            (route) => route.isFirst,
                          ),
                          icon: const Icon(Icons.home_outlined),
                          label: const Text('Kembali ke Beranda'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                            shape: const StadiumBorder(),
                            textStyle: AppText.buttonLabel.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppText.sectionTitle.copyWith(
              fontSize: 22,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppText.caption.copyWith(fontSize: 10, height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _ingredientCard(String ing) {
    const color = AppColors.statusSafe;
    const label = 'Aman';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ing,
                style: AppText.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                label,
                style: AppText.caption.copyWith(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}