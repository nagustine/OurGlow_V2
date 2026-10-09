import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../models/routine_product.dart';
import '../../models/enums.dart';
import '../../models/enums_ext.dart';
import '../../services/service_locator.dart';
import '../../widgets/app_navbar.dart';

class RoutineProductDetailScreen extends StatefulWidget {
  final RoutineProduct product;

  const RoutineProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<RoutineProductDetailScreen> createState() =>
      _RoutineProductDetailScreenState();
}

class _RoutineProductDetailScreenState
    extends State<RoutineProductDetailScreen> {
  late RoutineProduct _product;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  Future<void> _changeWaktu(WaktuPakai newWaktu) async {
    setState(() => _loading = true);
    try {
      final updated = _product.copyWith(waktuPakai: newWaktu);
      await ServiceLocator.routine.update(updated);
      if (!mounted) return;
      setState(() {
        _product = updated;
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Waktu pakai diubah ke ${newWaktu.label}'),
          backgroundColor: AppColors.statusSafe,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah: ${e.toString()}'),
          backgroundColor: AppColors.statusDanger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        title: Text(
          'Hapus produk?',
          style: AppText.cardTitle.copyWith(
            fontSize: 16,
            color: AppColors.primary,
          ),
        ),
        content: Text(
          '${_product.nama} akan dihapus dari rutinitasmu.',
          style: AppText.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: AppText.buttonLabel.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Hapus',
              style: AppText.buttonLabel.copyWith(
                color: AppColors.statusDanger,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ServiceLocator.routine.delete(_product.id);
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk dihapus dari rutinitas'),
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
      body: Column(
        children: [
          const AppNavbar(activeMenu: 'Routine Checker'),
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
                    const SizedBox(height: 20),
                    _buildInfoCard(),
                    const SizedBox(height: 16),
                    _buildBahanCard(),
                    const SizedBox(height: 16),
                    _buildWaktuCard(),
                    const SizedBox(height: 20),
                    _buildDeleteButton(),
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

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          color: AppColors.primary,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Produk',
                style: AppText.sectionTitle.copyWith(
                  fontSize: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Informasi produk di rutinitasmu',
                style: AppText.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.accent, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              _product.kategori.label,
              style: AppText.caption.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _product.nama,
            style: AppText.sectionTitle.copyWith(
              fontSize: 24,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _infoItem(
                  icon: Icons.schedule,
                  label: 'Waktu Pakai',
                  value: _product.waktuPakai.label,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoItem(
                  icon: Icons.format_list_numbered,
                  label: 'Urutan',
                  value: '${_product.urutan + 1}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent, size: 18),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppText.caption.copyWith(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppText.cardTitle.copyWith(
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBahanCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.science_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Bahan Aktif',
                style: AppText.cardTitle.copyWith(
                  fontSize: 15,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_product.bahan.isEmpty)
            Text(
              'Belum ada data bahan untuk produk ini.',
              style: AppText.bodySmall,
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _product.bahan
                  .map(
                    (b) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        b,
                        style: AppText.caption.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildWaktuCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.edit_calendar_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Ubah Waktu Pakai',
                style: AppText.cardTitle.copyWith(
                  fontSize: 15,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: WaktuPakai.values.map((w) {
              final active = _product.waktuPakai == w;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: _loading ? null : () => _changeWaktu(w),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: active
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        w.label,
                        textAlign: TextAlign.center,
                        style: AppText.caption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: active ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _loading ? null : _deleteProduct,
        icon: const Icon(Icons.delete_outline, size: 18),
        label: const Text('Hapus dari Rutinitas'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.statusDanger,
          side: const BorderSide(
            color: AppColors.statusDanger,
            width: 1.5,
          ),
          shape: const StadiumBorder(),
        ),
      ),
    );
  }
}