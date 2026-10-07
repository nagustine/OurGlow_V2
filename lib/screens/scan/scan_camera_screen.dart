import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/theme.dart';
import '../../widgets/app_navbar.dart';
import 'scan_review_screen.dart';

class ScanCameraScreen extends StatefulWidget {
  const ScanCameraScreen({super.key});

  @override
  State<ScanCameraScreen> createState() => _ScanCameraScreenState();
}

class _ScanCameraScreenState extends State<ScanCameraScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  bool _processing = false;

  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked == null) return;
      if (!mounted) return;
      setState(() => _pickedImage = picked);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal ambil foto: ${e.toString()}'),
          backgroundColor: AppColors.statusDanger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _processImage() async {
    if (_pickedImage == null) return;
    setState(() => _processing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _processing = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScanReviewScreen(
          rawText: '',
          fotoPath: _pickedImage!.path,
          fromOcr: true,
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
          const AppNavbar(activeMenu: 'Scan Produk'),
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
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.accent.withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                size: 22,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Scan Ingredients',
                                    style: AppText.cardTitle
                                        .copyWith(fontSize: 18),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Pilih foto label produk',
                                    style: AppText.caption,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 320,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  AppColors.primary.withValues(alpha: 0.15),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _pickedImage != null
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    _buildImagePreview(_pickedImage!.path),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () => setState(
                                            () => _pickedImage = null),
                                        child: Container(
                                          padding:
                                              const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: AppColors.statusDanger,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : _buildEmptyState(),
                        ),
                        const SizedBox(height: 20),
                        if (_pickedImage == null)
                          SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(
                                Icons.photo_library_outlined,
                              ),
                              label: const Text('Pilih dari Galeri'),
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
                          )
                        else ...[
                          SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _processing ? null : _processImage,
                              icon: _processing
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.auto_awesome),
                              label: Text(
                                _processing
                                    ? 'Reading ingredients...'
                                    : 'Baca Ingredients',
                              ),
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
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () =>
                                setState(() => _pickedImage = null),
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Ganti Foto'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Pastikan label komposisi terlihat jelas dan tidak terpotong. Foto dari jarak dekat dengan pencahayaan yang cukup.',
                                  style: AppText.bodySmall
                                      .copyWith(height: 1.5),
                                ),
                              ),
                            ],
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

  Widget _buildImagePreview(String path) {
    if (kIsWeb) {
      return Image.network(path, fit: BoxFit.cover);
    }
    return Image.file(File(path), fit: BoxFit.cover);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Belum ada foto',
            style: AppText.cardTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Pilih foto label produk dari galeri',
            style: AppText.caption,
          ),
        ],
      ),
    );
  }
}