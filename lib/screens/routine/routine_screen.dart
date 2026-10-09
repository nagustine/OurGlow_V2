import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../models/routine_product.dart';
import '../../models/enums.dart';
import '../../models/enums_ext.dart';
import '../../models/routine_check_result.dart';
import '../../services/service_locator.dart';
import '../../services/routine_analyzer.dart';
import '../../widgets/app_navbar.dart';
import '../../widgets/loading_overlay.dart';
import 'widgets/routine_tabs.dart';
import '../../models/routine_product_card.dart';
import 'widgets/conflict_warning.dart';
import 'routine_pick_product_screen.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  List<RoutineProduct> _products = [];
  bool _loading = true;
  String? _error;
  WaktuPakai _activeTab = WaktuPakai.pagi;

  // ignore: prefer_final_fields
  RoutineCheckResult _checkResult = RoutineCheckResult.empty();

  final ScrollController _scrollController = ScrollController();
  bool _showProductPicker = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ServiceLocator.routine.getAll();
      if (!mounted) return;
      setState(() {
        _products = list;
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

  List<RoutineProduct> get _filteredProducts {
    return _products
        .where((p) =>
            p.waktuPakai == _activeTab ||
            p.waktuPakai == WaktuPakai.pagiDanMalam)
        .toList()
      ..sort((a, b) => a.urutan.compareTo(b.urutan));
  }

  Future<void> _addProduct() async {
    final navigator = Navigator.of(context);
    await navigator.push(
      MaterialPageRoute(
        builder: (_) => const RoutinePickProductScreen(),
      ),
    );
    if (!mounted) return;
    _loadProducts();
  }

  Future<void> _startCheck() async {
    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tambahkan produk dulu ke rutinitasmu sebelum memulai pengecekan',
          ),
          backgroundColor: AppColors.statusWarning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _showProductPicker = true);

    await Future.delayed(const Duration(milliseconds: 150));
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _runAnalysis() async {
    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada produk untuk dianalisis'),
          backgroundColor: AppColors.statusWarning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final result = await RoutineAnalyzer.analyze(_products);

    if (!mounted) return;
    setState(() {
      _checkResult = result;
      _showProductPicker = false;
      _loading = false;
    });

    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.dataComplete
              ? 'Analisis selesai! Skor: ${result.score?.toStringAsFixed(0)}/100'
              : 'Data produk belum cukup untuk analisis lengkap',
        ),
        backgroundColor: result.dataComplete
            ? AppColors.statusSafe
            : AppColors.statusWarning,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteProduct(RoutineProduct product) async {
    try {
      await ServiceLocator.routine.delete(product.id);
      if (!mounted) return;
      setState(() {
        _products.removeWhere((p) => p.id == product.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.nama} dihapus dari routine'),
          backgroundColor: AppColors.statusSafe,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus: ${e.toString()}'),
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
      drawer: const AppDrawer(activeMenu: 'Routine Checker'),
      body: LoadingOverlay(
        isLoading: _loading,
        child: Column(
          children: [
            const AppNavbar(activeMenu: 'Routine Checker'),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadProducts,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  controller: _scrollController,
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
                                  _buildHeroBanner(),
                                  const SizedBox(height: 16),
                                  _buildAddProductButton(),
                                  const SizedBox(height: 16),
                                  _buildStatsRow(),
                                  const SizedBox(height: 20),
                                  _buildResultCard(),
                                  if (_checkResult.warnings.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    _buildWarningsList(),
                                  ],
                                  if (_checkResult
                                      .recommendations.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    _buildRecommendationsList(),
                                  ],
                                  const SizedBox(height: 20),
                                  if (_showProductPicker) ...[
                                    _buildPickerTitle(),
                                    const SizedBox(height: 12),
                                  ],
                                  RoutineTabs(
                                    activeTab: _activeTab,
                                    onTabChanged: (t) =>
                                        setState(() => _activeTab = t),
                                    pagiCount: _products
                                        .where((p) =>
                                            p.waktuPakai ==
                                                WaktuPakai.pagi ||
                                            p.waktuPakai ==
                                                WaktuPakai.pagiDanMalam)
                                        .length,
                                    malamCount: _products
                                        .where((p) =>
                                            p.waktuPakai ==
                                                WaktuPakai.malam ||
                                            p.waktuPakai ==
                                                WaktuPakai.pagiDanMalam)
                                        .length,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildProductsList(),
                                  const SizedBox(height: 16),
                                  ConflictWarning(products: _products),
                                ],
                              ),
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
      ),
    );
  }

  Widget _buildHeroBanner() {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroText(),
                const SizedBox(height: 16),
                Center(child: _buildHeroImage()),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildHeroText()),
                const SizedBox(width: 24),
                _buildHeroImage(),
              ],
            ),
    );
  }

  Widget _buildHeroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            'Cek rutinitas skincare-mu!',
            style: AppText.badge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Routine\nChecker',
          style: AppText.sectionTitle.copyWith(
            fontSize: 36,
            height: 1.1,
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kenali kecocokan produk dan potensi konflik bahan dalam '
          'rutinitas skincare-mu.',
          style: AppText.body.copyWith(
            fontSize: 14,
            color: AppColors.primary.withValues(alpha: 0.85),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return Image.asset(
      'assets/images/routine.png',
      height: 200,
      fit: BoxFit.contain,
    );
  }

  Widget _buildAddProductButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _addProduct,
        icon: const Icon(Icons.add_circle_outline, size: 22),
        label: const Text('Tambah Produk'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const StadiumBorder(),
          textStyle: AppText.buttonLabel.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.wb_sunny_outlined,
            value:
                '${_products.where((p) => p.waktuPakai == WaktuPakai.pagi || p.waktuPakai == WaktuPakai.pagiDanMalam).length}',
            label: 'Pagi',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: Icons.nights_stay_outlined,
            value:
                '${_products.where((p) => p.waktuPakai == WaktuPakai.malam || p.waktuPakai == WaktuPakai.pagiDanMalam).length}',
            label: 'Malam',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: Icons.inventory_2_outlined,
            value: '${_products.length}',
            label: 'Total',
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppText.cardTitle.copyWith(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: AppText.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartCheckButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _startCheck,
        icon: const Icon(Icons.play_arrow_rounded, size: 22),
        label: const Text('Mulai Cek Rutinitas'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.primary,
          elevation: 0,
          shape: const StadiumBorder(),
          textStyle: AppText.buttonLabel.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildPickerTitle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.edit_note_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih & Atur Produk',
                  style: AppText.cardTitle.copyWith(
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pilih produk skincare, tentukan rutinitas pagi/malam, '
                  'dan periksa kelengkapan ingredients.',
                  style: AppText.caption.copyWith(
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final result = _checkResult;
    final hasScore = result.score != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: result.statusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(result.statusIcon, color: result.statusColor, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hasil Analisis Rutinitas',
                  style: AppText.cardTitle.copyWith(
                    fontSize: 15,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: result.statusColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: result.statusColor.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      hasScore ? result.score!.toStringAsFixed(0) : '—',
                      style: AppText.sectionTitle.copyWith(
                        fontSize: 26,
                        color: result.statusColor,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      hasScore ? '/100' : 'skor',
                      style: AppText.caption.copyWith(
                        fontSize: 10,
                        color: result.statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.statusLabel,
                      style: AppText.cardTitle.copyWith(
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.statusDescription,
                      style: AppText.caption.copyWith(
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _summaryItem(
                    icon: Icons.check_circle_outline,
                    color: AppColors.statusSafe,
                    count: result.safeCount,
                    label: 'Aman',
                  ),
                ),
                Expanded(
                  child: _summaryItem(
                    icon: Icons.info_outline,
                    color: AppColors.statusWarning,
                    count: result.warningCount,
                    label: 'Perhatian',
                  ),
                ),
                Expanded(
                  child: _summaryItem(
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.statusDanger,
                    count: result.conflictCount,
                    label: 'Konflik',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Catatan: skor dihitung dari aturan yang diterapkan dalam '
            'program, bukan angka acak atau diagnosis medis.',
            style: AppText.caption.copyWith(
              fontSize: 10.5,
              color: AppColors.neutral,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _buildStartCheckButton(),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required Color color,
    required int count,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: AppText.cardTitle.copyWith(
            fontSize: 16,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: AppText.caption.copyWith(
            fontSize: 10,
            color: AppColors.neutral,
          ),
        ),
      ],
    );
  }

  Widget _buildWarningsList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.statusWarning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.statusWarning.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.statusWarning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Peringatan (${_checkResult.warnings.length})',
                style: AppText.cardTitle.copyWith(
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._checkResult.warnings.map(
            (w) => Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(
                      w,
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

  Widget _buildRecommendationsList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.statusSafe.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.statusSafe.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tips_and_updates_outlined,
                color: AppColors.statusSafe,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Rekomendasi',
                style: AppText.cardTitle.copyWith(
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._checkResult.recommendations.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(
                      r,
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

  Widget _buildProductsList() {
    final products = _filteredProducts;

    if (products.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.spa_outlined,
              size: 48,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada produk di rutinitas ${_activeTab.label}',
              style: AppText.cardTitle.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Klik tombol "Tambah Produk" di atas untuk menambahkan produk',
              textAlign: TextAlign.center,
              style: AppText.caption,
            ),
            if (_showProductPicker) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _runAnalysis,
                  icon: const Icon(Icons.analytics_outlined, size: 20),
                  label: const Text('Analisis Sekarang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    textStyle: AppText.buttonLabel.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        ...List.generate(products.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RoutineProductCard(
              product: products[i],
              urutan: i + 1,
              onDelete: () => _deleteProduct(products[i]),
            ),
          );
        }),
        if (_showProductPicker) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _runAnalysis,
              icon: const Icon(Icons.analytics_outlined, size: 20),
              label: const Text('Analisis Sekarang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const StadiumBorder(),
                textStyle: AppText.buttonLabel.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ],
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
              onPressed: _loadProducts,
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