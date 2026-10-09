import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../models/product.dart';
import '../../models/routine_product.dart';
import '../../models/enums.dart';
import '../../data/mock_products.dart';
import '../../services/service_locator.dart';

class RoutinePickProductScreen extends StatefulWidget {
  const RoutinePickProductScreen({super.key});

  @override
  State<RoutinePickProductScreen> createState() =>
      _RoutinePickProductScreenState();
}

class _RoutinePickProductScreenState extends State<RoutinePickProductScreen> {
  final _searchCtrl = TextEditingController();
  final _manualNamaCtrl = TextEditingController();
  final _manualBahanCtrl = TextEditingController();

  KategoriProduk? _filterKategori;
  String _query = '';
  bool _isManual = false;

  final Set<String> _selectedIngredients = {};

  @override
  void initState() {
    super.initState();
    ServiceLocator.ingredients.load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _manualNamaCtrl.dispose();
    _manualBahanCtrl.dispose();
    super.dispose();
  }

  List<Product> get _filtered {
    return mockProducts.where((p) {
      final matchQuery = _query.isEmpty ||
          p.nama.toLowerCase().contains(_query.toLowerCase());
      final matchKategori =
          _filterKategori == null || p.kategori == _filterKategori;
      return matchQuery && matchKategori;
    }).toList();
  }

  Future<void> _openIngredientPicker(Product product) async {
    _selectedIngredients.clear();

    await ServiceLocator.ingredients.load();
    if (!mounted) return;

    final picked = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _buildIngredientPickerSheet(product),
    );

    if (picked == null) return;
    if (!mounted) return;

    if (picked.isEmpty) {
      _showError('Pilih minimal satu bahan untuk produk ini');
      return;
    }

    final waktu = await showModalBottomSheet<WaktuPakai>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _buildWaktuPickerSheet(product.nama),
    );

    if (waktu == null) return;
    if (!mounted) return;

    try {
      final existing = await ServiceLocator.routine.getAll();
      final rp = RoutineProduct(
        id: '${product.id}_${DateTime.now().millisecondsSinceEpoch}',
        nama: product.nama,
        kategori: product.kategori,
        waktuPakai: waktu,
        urutan: existing.length,
        bahan: picked,
      );
      await ServiceLocator.routine.add(rp);

      if (!mounted) return;
      _showSuccess('${product.nama} ditambahkan ke rutinitas');
    } catch (e) {
      if (!mounted) return;
      _showError('Gagal menambahkan: $e');
    }
  }

  Future<void> _addManualToRoutine() async {
    final nama = _manualNamaCtrl.text.trim();
    final bahanRaw = _manualBahanCtrl.text.trim();

    if (nama.isEmpty) {
      _showError('Nama produk wajib diisi');
      return;
    }
    if (bahanRaw.isEmpty) {
      _showError('Isi minimal satu bahan');
      return;
    }

    await ServiceLocator.ingredients.load();
    final matched = ServiceLocator.ingredients.matchText(bahanRaw);
    final matchedIds = matched.map((m) => m.id).toSet().toList();

    if (!mounted) return;

    if (matchedIds.isEmpty) {
      _showError(
        'Bahan tidak dikenali. Coba pakai nama INCI (contoh: niacinamide, retinol).',
      );
      return;
    }

    final waktu = await showModalBottomSheet<WaktuPakai>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _buildWaktuPickerSheet(nama),
    );

    if (waktu == null) return;
    if (!mounted) return;

    try {
      final existing = await ServiceLocator.routine.getAll();
      final rp = RoutineProduct(
        id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
        nama: nama,
        kategori: KategoriProduk.lainnya,
        waktuPakai: waktu,
        urutan: existing.length,
        bahan: matchedIds,
      );
      await ServiceLocator.routine.add(rp);

      if (!mounted) return;
      _showSuccess('$nama ditambahkan (${matchedIds.length} bahan dikenali)');

      _manualNamaCtrl.clear();
      _manualBahanCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      _showError('Gagal menambahkan: $e');
    }
  }

  Widget _buildIngredientPickerSheet(Product product) {
    final allIngredients = ServiceLocator.ingredients.all;

    return StatefulBuilder(
      builder: (context, setSheetState) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollCtrl) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.neutral,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Text(
                    'Pilih Kandungan',
                    style: AppText.cardTitle.copyWith(
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih bahan yang ada di ${product.nama} milikmu',
                    style: AppText.caption,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollCtrl,
                      itemCount: allIngredients.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final ing = allIngredients[i];
                        final selected =
                            _selectedIngredients.contains(ing.id);

                        return InkWell(
                          onTap: () {
                            setSheetState(() {
                              if (selected) {
                                _selectedIngredients.remove(ing.id);
                              } else {
                                _selectedIngredients.add(ing.id);
                              }
                            });
                          },
                          borderRadius:
                              BorderRadius.circular(AppRadius.card),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.accent.withValues(alpha: 0.2)
                                  : AppColors.background,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.card),
                              border: Border.all(
                                color: selected
                                    ? AppColors.accent
                                    : AppColors.primary
                                        .withValues(alpha: 0.1),
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.primary
                                              .withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: selected
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ing.name,
                                        style: AppText.cardTitle.copyWith(
                                          fontSize: 13,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        ing.kategori.name,
                                        style: AppText.caption.copyWith(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_selectedIngredients.length} bahan dipilih',
                    style: AppText.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          _selectedIngredients.toList(),
                        );
                      },
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
                      child: const Text('Lanjut Pilih Waktu'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWaktuPickerSheet(String namaProduk) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.neutral,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Text(
              'Kapan $namaProduk dipakai?',
              style: AppText.cardTitle.copyWith(
                fontSize: 16,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Pilih waktu pemakaian untuk produk ini',
              style: AppText.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _waktuOption(
              icon: Icons.wb_sunny_outlined,
              label: 'Pagi',
              value: WaktuPakai.pagi,
            ),
            const SizedBox(height: 10),
            _waktuOption(
              icon: Icons.nights_stay_outlined,
              label: 'Malam',
              value: WaktuPakai.malam,
            ),
            const SizedBox(height: 10),
            _waktuOption(
              icon: Icons.brightness_2_outlined,
              label: 'Pagi & Malam',
              value: WaktuPakai.pagiDanMalam,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _waktuOption({
    required IconData icon,
    required String label,
    required WaktuPakai value,
  }) {
    return InkWell(
      onTap: () => Navigator.pop(context, value),
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: AppColors.accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppText.cardTitle.copyWith(
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.neutral,
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.statusSafe,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.statusDanger,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
          _buildNavbar(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: hPad,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildModeToggle(),
                    const SizedBox(height: 16),
                    if (_isManual) ..._buildManualForm() else ...[
                      _buildSearchBar(),
                      const SizedBox(height: 12),
                      _buildCategoryFilters(),
                      const SizedBox(height: 16),
                      _buildProductGrid(),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavbar() {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              'Pilih Produk',
              style: AppText.cardTitle.copyWith(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Produk',
          style: AppText.sectionTitle.copyWith(
            fontSize: 22,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pilih jenis produk, lalu pilih kandungannya',
          style: AppText.caption,
        ),
      ],
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _modeButton(
              icon: Icons.grid_view_rounded,
              label: 'Katalog',
              active: !_isManual,
              onTap: () => setState(() => _isManual = false),
            ),
          ),
          Expanded(
            child: _modeButton(
              icon: Icons.edit_note,
              label: 'Input Manual',
              active: _isManual,
              onTap: () => setState(() => _isManual = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeButton({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppText.badge.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildManualForm() {
    return [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.tips_and_updates_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Input bahan skincare secara manual',
                    style: AppText.cardTitle.copyWith(
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Tulis nama produk dan daftar bahan yang digunakan, '
              'pisahkan dengan koma. Contoh: niacinamide, retinol, bha.',
              style: AppText.caption.copyWith(
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            _buildLabel('Nama Produk'),
            const SizedBox(height: 6),
            TextField(
              controller: _manualNamaCtrl,
              style: AppText.body,
              decoration: _inputDecoration('Contoh: Serum Malam-ku'),
            ),
            const SizedBox(height: 14),
            _buildLabel('Daftar Bahan'),
            const SizedBox(height: 6),
            TextField(
              controller: _manualBahanCtrl,
              maxLines: 4,
              style: AppText.body,
              decoration: _inputDecoration(
                'niacinamide, retinol, salicylic acid',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _addManualToRoutine,
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text('Tambah ke Rutinitas'),
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
        ),
      ),
    ];
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: AppText.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
        borderSide: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
        borderSide: const BorderSide(
          color: AppColors.accent,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchCtrl,
      onChanged: (v) => setState(() => _query = v),
      style: AppText.body,
      decoration: InputDecoration(
        hintText: 'Cari produk...',
        prefixIcon: const Icon(
          Icons.search,
          size: 20,
          color: AppColors.primary,
        ),
        suffixIcon: _query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() => _query = '');
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.cream,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: const BorderSide(
            color: AppColors.accent,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip('Semua', null),
          const SizedBox(width: 8),
          ...KategoriProduk.values.map(
            (k) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _chip(_kategoriLabel(k), k),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, KategoriProduk? kategori) {
    final active = _filterKategori == kategori;
    return GestureDetector(
      onTap: () => setState(() => _filterKategori = kategori),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.cream,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: active
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.15),
          ),
        ),
        child: Text(
          label,
          style: AppText.badge.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }

  String _kategoriLabel(KategoriProduk k) {
    switch (k) {
      case KategoriProduk.cleanser:
        return 'Cleanser';
      case KategoriProduk.toner:
        return 'Toner';
      case KategoriProduk.serum:
        return 'Serum';
      case KategoriProduk.moisturizer:
        return 'Moisturizer';
      case KategoriProduk.sunscreen:
        return 'Sunscreen';
      case KategoriProduk.exfoliator:
        return 'Exfoliator';
      case KategoriProduk.masker:
        return 'Masker';
      case KategoriProduk.lainnya:
        return 'Lainnya';
    }
  }

  Widget _buildProductGrid() {
    final products = _filtered;

    if (products.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'Produk tidak ditemukan',
              style: AppText.cardTitle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Coba kata kunci lain atau ubah filter',
              style: AppText.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 600
                ? 3
                : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: products.length,
          itemBuilder: (context, i) {
            return _buildProductCard(products[i]);
          },
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final foto = product.fotoUrl;

    return InkWell(
      onTap: () => _openIngredientPicker(product),
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.card),
                ),
                child: Container(
                  color: AppColors.background,
                  child: (foto == null || foto.isEmpty)
                      ? Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 32,
                            color: AppColors.primary.withValues(alpha: 0.4),
                          ),
                        )
                      : Image.asset(
                          foto,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 32,
                              color:
                                  AppColors.primary.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.25),
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            _kategoriLabel(product.kategori),
                            style: AppText.caption.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          product.nama,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.cardTitle.copyWith(
                            fontSize: 12,
                            color: AppColors.primary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: ElevatedButton.icon(
                        onPressed: () => _openIngredientPicker(product),
                        icon: const Icon(Icons.tune, size: 12),
                        label: const Text('Pilih Kandungan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: const StadiumBorder(),
                          textStyle: AppText.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}