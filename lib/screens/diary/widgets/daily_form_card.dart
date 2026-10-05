import 'package:flutter/material.dart';
import '../../../theme/theme.dart';
import '../../../models/enums.dart';
import '../../../models/enums_ext.dart';
import '../../../models/product.dart';

class DailyFormCard extends StatefulWidget {
  final DateTime tanggal;
  final List<KondisiKulit> initialKondisi;
  final int initialIntensitas;
  final List<Product> initialProduk;
  final String initialCatatan;
  final List<Product> produkTersedia;
  final Function({
    required List<KondisiKulit> kondisi,
    required int intensitas,
    required List<Product> produk,
    required String catatan,
  }) onSave;

  const DailyFormCard({
    super.key,
    required this.tanggal,
    required this.initialKondisi,
    required this.initialIntensitas,
    required this.initialProduk,
    required this.initialCatatan,
    required this.produkTersedia,
    required this.onSave,
  });

  @override
  State<DailyFormCard> createState() => _DailyFormCardState();
}

class _DailyFormCardState extends State<DailyFormCard> {
  late List<KondisiKulit> _kondisi;
  late double _intensitas;
  late List<Product> _produk;
  late TextEditingController _catatanCtrl;

  @override
  void initState() {
    super.initState();
    _kondisi = List.from(widget.initialKondisi);
    _intensitas = widget.initialIntensitas.toDouble();
    _produk = List.from(widget.initialProduk);
    _catatanCtrl = TextEditingController(text: widget.initialCatatan);
  }

  @override
  void dispose() {
    _catatanCtrl.dispose();
    super.dispose();
  }

  void _toggleKondisi(KondisiKulit k) {
    setState(() {
      if (_kondisi.contains(k)) {
        _kondisi.remove(k);
      } else {
        _kondisi.add(k);
      }
    });
  }

  void _tambahProduk(Product p) {
    if (_produk.any((e) => e.id == p.id)) return;
    setState(() => _produk.add(p));
  }

  void _hapusProduk(Product p) {
    setState(() => _produk.removeWhere((e) => e.id == p.id));
  }

  IconData _iconFor(KondisiKulit k) {
    switch (k) {
      case KondisiKulit.glowing:
        return Icons.auto_awesome;
      case KondisiKulit.normal:
        return Icons.sentiment_satisfied_alt;
      case KondisiKulit.berminyak:
        return Icons.water_drop_outlined;
      case KondisiKulit.kering:
        return Icons.grain;
      case KondisiKulit.berjerawat:
        return Icons.warning_amber_rounded;
      case KondisiKulit.iritasi:
        return Icons.local_fire_department_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Icons.edit_note,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Catat Kondisi Kulit',
                  style: AppText.cardTitle.copyWith(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ─── KONDISI KULIT ───
          Text(
            'Kondisi kulit hari ini',
            style: AppText.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: KondisiKulit.values.map((k) {
              final active = _kondisi.contains(k);
              return GestureDetector(
                onTap: () => _toggleKondisi(k),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        active ? AppColors.primary : AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: active
                          ? AppColors.accent
                          : AppColors.primary.withValues(alpha: 0.15),
                      width: active ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _iconFor(k),
                        size: 16,
                        color:
                            active ? Colors.white : AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        k.label,
                        style: AppText.badge.copyWith(
                          fontSize: 12,
                          color:
                              active ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ─── INTENSITAS ───
          Row(
            children: [
              Text(
                'Intensitas',
                style: AppText.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Text(
                '${_intensitas.toStringAsFixed(0)}%',
                style: AppText.badge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor:
                  AppColors.primary.withValues(alpha: 0.15),
              thumbColor: AppColors.accent,
              overlayColor: AppColors.accent.withValues(alpha: 0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: _intensitas,
              min: 0,
              max: 100,
              divisions: 20,
              onChanged: (v) => setState(() => _intensitas = v),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ─── PRODUK YANG DIPAKAI ───
          Row(
            children: [
              Text(
                'Produk yang dipakai',
                style: AppText.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Text('${_produk.length} produk', style: AppText.caption),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          if (_produk.isNotEmpty)
            SizedBox(
              height: 76,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _produk.length + 1,
                itemBuilder: (context, i) {
                  if (i == _produk.length) return _addButton();
                  return _productChip(_produk[i]);
                },
              ),
            )
          else
            _addButton(),
          const SizedBox(height: AppSpacing.lg),

          // ─── CATATAN ───
          Text(
            'Catatan',
            style: AppText.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _catatanCtrl,
            maxLines: null,
            minLines: 3,
            style: AppText.body,
            decoration: InputDecoration(
              hintText: 'Bagaimana kondisi kulitmu hari ini?',
              hintStyle: AppText.body.copyWith(
                color: AppColors.textDark.withValues(alpha: 0.4),
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.all(14),
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
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ─── TOMBOL SIMPAN ───
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onSave(
                  kondisi: _kondisi,
                  intensitas: _intensitas.round(),
                  produk: _produk,
                  catatan: _catatanCtrl.text.trim(),
                );
              },
              icon: const Icon(Icons.save_outlined, size: 18),
              label: Text(
                'Simpan Catatan',
                style: AppText.buttonLabel.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: _showProductPicker,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.accent,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.add,
            color: AppColors.primary,
            size: 26,
          ),
        ),
      ),
    );
  }

  Widget _productChip(Product p) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              p.fotoUrl ?? '',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.spa_outlined,
                color: AppColors.primary,
              ),
            ),
          ),
          Positioned(
            top: -4,
            right: -4,
            child: GestureDetector(
              onTap: () => _hapusProduk(p),
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.statusDanger,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.close,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProductPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih Produk',
                  style: AppText.cardTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pilih produk yang kamu pakai hari ini',
                  style: AppText.caption,
                ),
                const SizedBox(height: AppSpacing.md),
                ...widget.produkTersedia.map((p) {
                  final isUsed = _produk.any((e) => e.id == p.id);
                  return InkWell(
                    onTap: () {
                      if (isUsed) {
                        _hapusProduk(p);
                      } else {
                        _tambahProduk(p);
                      }
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              p.fotoUrl ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.spa_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.nama,
                                  style: AppText.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  p.labelKategori,
                                  style: AppText.caption,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isUsed
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: isUsed
                                ? AppColors.statusSafe
                                : AppColors.neutral,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}