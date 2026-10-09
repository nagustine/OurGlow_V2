import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/back_navbar.dart';
import 'scan_result_screen.dart';

class ScanReviewScreen extends StatefulWidget {
  final String rawText;
  final String? fotoPath;
  final bool fromOcr;

  const ScanReviewScreen({
    super.key,
    required this.rawText,
    this.fotoPath,
    this.fromOcr = false,
  });

  @override
  State<ScanReviewScreen> createState() => _ScanReviewScreenState();
}

class _ScanReviewScreenState extends State<ScanReviewScreen> {
  late TextEditingController _ctrl;
  bool _edited = false;

  static const List<String> _mockOcrResults = [
    'Aqua, Glycerin, Hyaluronic Acid, Panthenol, Ceramide',
    'Aqua, Niacinamide, Alpha Arbutin, Tranexamic Acid, Glycerin',
    'Aqua, Salicylic Acid, Niacinamide, Zinc PCA, Glycerin',
    'Aqua, Retinol, Peptide, Hyaluronic Acid, Tocopherol',
  ];

  @override
  void initState() {
    super.initState();
    final initial = widget.rawText.isNotEmpty
        ? widget.rawText
        : _mockOcrResults[Random().nextInt(_mockOcrResults.length)];
    _ctrl = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _analisis() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Komposisi tidak boleh kosong'),
          backgroundColor: AppColors.statusWarning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScanResultScreen(
          rawText: text,
          fotoPath: widget.fotoPath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const BackNavbar(title: 'Review Ingredients'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.accent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.fotoPath != null) ...[
                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary
                                    .withValues(alpha: 0.15),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: kIsWeb
                                ? Image.network(
                                    widget.fotoPath!,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(widget.fotoPath!),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        if (widget.fromOcr)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.statusSafe
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.statusSafe
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 20,
                                  color: AppColors.statusSafe,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ingredients detected',
                                        style:
                                            AppText.bodySmall.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.statusSafe,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Please review the detected ingredients before analyzing.',
                                        style: AppText.caption
                                            .copyWith(height: 1.4),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (widget.fromOcr) const SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              'Ingredients',
                              style:
                                  AppText.cardTitle.copyWith(fontSize: 16),
                            ),
                            const Spacer(),
                            if (_edited)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent
                                      .withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Edited',
                                  style: AppText.caption.copyWith(
                                    fontSize: 10,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Perbaiki jika ada yang salah baca',
                          style: AppText.caption,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _ctrl,
                          maxLines: null,
                          minLines: 6,
                          onChanged: (_) {
                            if (!_edited) setState(() => _edited = true);
                          },
                          style: AppText.body.copyWith(height: 1.6),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.all(18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: AppColors.primary
                                    .withValues(alpha: 0.15),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: AppColors.accent,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _analisis,
                            icon: const Icon(Icons.search),
                            label: const Text('Analisis Sekarang'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              textStyle: AppText.buttonLabel.copyWith(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}