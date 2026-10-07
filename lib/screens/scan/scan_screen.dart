import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../models/scan_result.dart';
import '../../models/enums.dart';
import '../../services/service_locator.dart';
import '../../widgets/app_navbar.dart';
import 'scan_camera_screen.dart';
import 'scan_manual_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<ScanResult> _riwayat = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ServiceLocator.scan.getAll();
      if (!mounted) return;
      setState(() {
        _riwayat = list;
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;
    final hPad = isDesktop ? 60.0 : 16.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppNavbar(activeMenu: 'Scan Produk'),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadRiwayat,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeroSection(isDesktop: isDesktop, hPad: hPad),
                    const SizedBox(height: 8),
                    _MainScanCard(
                      isDesktop: isDesktop,
                      hPad: hPad,
                      onAfterScan: _loadRiwayat,
                    ),
                    const SizedBox(height: 16),
                    _ScanTips(hPad: hPad),
                    const SizedBox(height: 16),
                    _RiwayatSection(
                      hPad: hPad,
                      riwayat: _riwayat,
                      loading: _loading,
                      error: _error,
                      onRefresh: _loadRiwayat,
                    ),
                    const SizedBox(height: 24),
                    const _CopyrightBar(),
                  ],
                ),
              ),
            ),
          ),
        ],
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

class _HeroSection extends StatelessWidget {
  final bool isDesktop;
  final double hPad;

  const _HeroSection({required this.isDesktop, required this.hPad});

  @override
  Widget build(BuildContext context) {
    final content = isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 5, child: _buildTextContent()),
              const SizedBox(width: 24),
              Expanded(flex: 4, child: _buildIllustration()),
            ],
          )
        : Column(
            children: [
              _buildTextContent(),
              const SizedBox(height: 16),
              _buildIllustration(),
            ],
          );

    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: EdgeInsets.symmetric(
        horizontal: hPad,
        vertical: isDesktop ? 32 : 20,
      ),
      child: content,
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment:
          isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            'Kenali kandungan skincare sebelum menyentuh kulitmu!',
            style: AppText.badge.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Scan Produk',
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: AppText.heroTitle.copyWith(
            fontSize: isDesktop ? 48 : 32,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Skincare Checker',
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: AppText.sectionTitle.copyWith(
            fontSize: isDesktop ? 24 : 18,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Cek komposisi, pahami fungsinya, dan ketahui apakah sesuai dengan jenis kulitmu.',
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: AppText.body.copyWith(
            fontSize: isDesktop ? 15 : 13.5,
            color: AppColors.textDark.withValues(alpha: 0.8),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      height: isDesktop ? 280 : 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            top: 10,
            right: 20,
            child: Icon(
              Icons.auto_awesome,
              size: 24,
              color: AppColors.accent,
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            child: Icon(
              Icons.auto_awesome,
              size: 16,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: Icon(
              Icons.auto_awesome,
              size: 14,
              color: AppColors.accent.withValues(alpha: 0.7),
            ),
          ),
          Image.asset(
            AppAssets.checker,
            height: isDesktop ? 280 : 200,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  size: 48,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'checker.png belum ke-load',
                  style: AppText.caption.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MainScanCard extends StatelessWidget {
  final bool isDesktop;
  final double hPad;
  final VoidCallback onAfterScan;

  const _MainScanCard({
    required this.isDesktop,
    required this.hPad,
    required this.onAfterScan,
  });

  @override
  Widget build(BuildContext context) {
    Future<void> goToScan(Widget page) async {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
      onAfterScan();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: hPad),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.6),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: isDesktop
          ? IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _PrimaryCard(
                      onTap: () => goToScan(const ScanCameraScreen()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SecondaryCard(
                      onTap: () => goToScan(const ScanManualScreen()),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                _PrimaryCard(
                  onTap: () => goToScan(const ScanCameraScreen()),
                ),
                const SizedBox(height: 12),
                _SecondaryCard(
                  onTap: () => goToScan(const ScanManualScreen()),
                ),
              ],
            ),
    );
  }
}

class _PrimaryCard extends StatelessWidget {
  final VoidCallback onTap;

  const _PrimaryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Scan Produk',
                style: AppText.sectionTitle.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Ambil foto label produk untuk membaca komposisi.',
                style: AppText.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Mulai Scan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.primary,
                    shape: const StadiumBorder(),
                    textStyle: AppText.buttonLabel.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryCard extends StatelessWidget {
  final VoidCallback onTap;

  const _SecondaryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.sectionBg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.edit_document,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter Manually',
                style: AppText.sectionTitle.copyWith(
                  color: AppColors.primary,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Ketik atau paste komposisi produk secara langsung.',
                style: AppText.bodySmall.copyWith(
                  color: AppColors.textDark.withValues(alpha: 0.75),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Tulis Komposisi'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                    shape: const StadiumBorder(),
                    textStyle: AppText.buttonLabel.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanTips extends StatelessWidget {
  final double hPad;

  const _ScanTips({required this.hPad});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: hPad),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.lightbulb_outline,
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
                  'Tips Scan',
                  style: AppText.cardTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pastikan pencahayaan cukup dan tulisan ingredients terlihat jelas agar hasil scan lebih akurat.',
                  style: AppText.bodySmall.copyWith(
                    fontSize: 12,
                    height: 1.5,
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

class _RiwayatSection extends StatelessWidget {
  final double hPad;
  final List<ScanResult> riwayat;
  final bool loading;
  final String? error;
  final VoidCallback onRefresh;

  const _RiwayatSection({
    required this.hPad,
    required this.riwayat,
    required this.loading,
    required this.error,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: hPad),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.sectionBg,
        borderRadius: BorderRadius.circular(28),
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
              Expanded(
                child: Text(
                  'Riwayat Scan Terbaru',
                  style: AppText.cardTitle.copyWith(fontSize: 16),
                ),
              ),
              if (riwayat.isNotEmpty)
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Fitur lihat semua akan tersedia di update berikutnya',
                        ),
                        backgroundColor: AppColors.statusWarning,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text(
                    'Lihat Semua',
                    style: AppText.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (error != null)
            _errorState()
          else if (riwayat.isEmpty)
            _emptyState()
          else
            ...riwayat.take(10).map((item) => _buildRow(item, context)),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 32,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 48,
            color: AppColors.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada riwayat scan',
            style: AppText.cardTitle.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Mulai scan produk untuk melihat riwayat di sini',
            textAlign: TextAlign.center,
            style: AppText.caption,
          ),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.statusDanger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 40,
            color: AppColors.statusDanger,
          ),
          const SizedBox(height: 12),
          Text(
            'Gagal memuat riwayat',
            style: AppText.cardTitle.copyWith(
              fontSize: 14,
              color: AppColors.statusDanger,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(ScanResult item, BuildContext context) {
    Color statusColor;
    String statusLabel;
    switch (item.status) {
      case StatusAman.aman:
        statusColor = AppColors.statusSafe;
        statusLabel = 'Aman';
        break;
      case StatusAman.perluPerhatian:
        statusColor = AppColors.statusWarning;
        statusLabel = 'Perlu Perhatian';
        break;
      case StatusAman.bentrok:
        statusColor = AppColors.statusDanger;
        statusLabel = 'Bentrok';
        break;
    }

    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Detail "${item.productName}" akan tersedia di update berikutnya',
                ),
                backgroundColor: AppColors.statusWarning,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${item.tanggal.day}',
                        style: AppText.cardTitle.copyWith(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1,
                        ),
                      ),
                      Text(
                        bulan[item.tanggal.month - 1],
                        style: AppText.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 8,
                          height: 1,
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
                        item.productName,
                        style: AppText.body.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.jumlahIngredients} bahan',
                        style: AppText.caption.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    statusLabel,
                    style: AppText.caption.copyWith(
                      fontSize: 9,
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}