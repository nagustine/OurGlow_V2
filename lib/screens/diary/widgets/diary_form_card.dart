import 'package:flutter/material.dart';
import '../../../theme/theme.dart';
import '../../../models/enums.dart';
import '../../../models/enums_ext.dart';
import '../../../models/diary_entry.dart';
import '../../../utils/product_icons.dart';
import '../diary_product_sheet.dart';

class DiaryFormCard extends StatefulWidget {
  final DateTime tanggal;
  final DiaryEntry? initial;
  final Function(DiaryEntry) onSave;

  const DiaryFormCard({
    super.key,
    required this.tanggal,
    this.initial,
    required this.onSave,
  });

  @override
  State<DiaryFormCard> createState() => _DiaryFormCardState();
}

class _DiaryFormCardState extends State<DiaryFormCard> {
  KondisiKulit _kondisi = KondisiKulit.normal;
  final Set<String> _masalah = {};
  double _intensitas = 50;
  final Set<String> _areaBermasalah = {};
  final List<DiaryProduct> _produk = [];
  final TextEditingController _catatanCtrl = TextEditingController();

  static const List<String> _masalahOptions = [
    'Jerawat',
    'Komedo',
    'Bruntusan',
    'Kemerahan',
    'Kering',
    'Minyak berlebih',
    'Kusam',
  ];

  static const List<String> _areaOptions = [
    'Dahi',
    'Pipi kiri',
    'Pipi kanan',
    'Hidung',
    'Dagu',
    'Rahang',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _kondisi = widget.initial!.kondisiUtama;
      _masalah.addAll(widget.initial!.masalah);
      _intensitas = widget.initial!.intensitas.toDouble();
      _areaBermasalah.addAll(widget.initial!.areaBermasalah);
      _produk.addAll(widget.initial!.produkDipakai);
      _catatanCtrl.text = widget.initial!.catatan;
    }
  }

  @override
  void dispose() {
    _catatanCtrl.dispose();
    super.dispose();
  }

  IconData _iconForKondisi(KondisiKulit k) {
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

  Future<void> _tambahProduk() async {
    final result = await showModalBottomSheet<DiaryProduct>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DiaryProductSheet(),
    );
    if (result != null) {
      setState(() => _produk.add(result));
    }
  }

  Future<void> _editProduk(int index) async {
    final result = await showModalBottomSheet<DiaryProduct>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DiaryProductSheet(initial: _produk[index]),
    );
    if (result != null) {
      setState(() => _produk[index] = result);
    }
  }

  void _hapusProduk(int index) {
    setState(() => _produk.removeAt(index));
  }

  void _save() {
    final entry = DiaryEntry(
      id: widget.initial?.id ??
          'diary_${widget.tanggal.millisecondsSinceEpoch}',
      tanggal: widget.tanggal,
      kondisiUtama: _kondisi,
      masalah: _masalah.toList(),
      intensitas: _intensitas.round(),
      areaBermasalah: _areaBermasalah.toList(),
      produkDipakai: _produk,
      catatan: _catatanCtrl.text.trim(),
    );
    widget.onSave(entry);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildKondisiSection(),
        const SizedBox(height: AppSpacing.lg),
        _buildMasalahSection(),
        const SizedBox(height: AppSpacing.lg),
        _buildIntensitasSection(),
        const SizedBox(height: AppSpacing.lg),
        _buildAreaSection(),
        const SizedBox(height: AppSpacing.lg),
        _buildProdukSection(),
        const SizedBox(height: AppSpacing.lg),
        _buildCatatanSection(),
        const SizedBox(height: AppSpacing.lg),
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildKondisiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Bagaimana kondisi kulitmu hari ini?'),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: KondisiKulit.values.map((k) {
            final active = _kondisi == k;
            return GestureDetector(
              onTap: () => setState(() => _kondisi = k),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: active
                        ? AppColors.accent
                        : AppColors.primary.withValues(alpha: 0.2),
                    width: active ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _iconForKondisi(k),
                      size: 16,
                      color: active ? Colors.white : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      k.label,
                      style: AppText.badge.copyWith(
                        fontSize: 12,
                        color: active ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMasalahSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Apa masalah yang kamu rasakan?'),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _masalahOptions.map((m) {
            final active = _masalah.contains(m);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (active) {
                    _masalah.remove(m);
                  } else {
                    _masalah.add(m);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.background,
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
                      active
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 16,
                      color: active ? Colors.white : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      m,
                      style: AppText.badge.copyWith(
                        fontSize: 12,
                        color: active ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIntensitasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _sectionTitle('Seberapa mengganggu?'),
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
        Row(
          children: [
            Text('Tidak', style: AppText.caption),
            Expanded(
              child: SliderTheme(
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
            ),
            Text('Sangat', style: AppText.caption),
          ],
        ),
      ],
    );
  }

  Widget _buildAreaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Area yang bermasalah'),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _areaOptions.map((a) {
            final active = _areaBermasalah.contains(a);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (active) {
                    _areaBermasalah.remove(a);
                  } else {
                    _areaBermasalah.add(a);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: active
                        ? AppColors.accent
                        : AppColors.primary.withValues(alpha: 0.15),
                    width: active ? 2 : 1,
                  ),
                ),
                child: Text(
                  a,
                  style: AppText.badge.copyWith(
                    fontSize: 12,
                    color: active ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProdukSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Produk yang digunakan hari ini'),
        const SizedBox(height: AppSpacing.sm),
        if (_produk.isNotEmpty) ...[
          ...List.generate(_produk.length, (i) {
            final p = _produk[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        ProductIcons.forKategori(p.kategori),
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.nama,
                            style: AppText.body.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            p.kategori,
                            style: AppText.caption.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _editProduk(i),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      color: AppColors.primary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      onPressed: () => _hapusProduk(i),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      color: AppColors.statusDanger,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: _tambahProduk,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Tambah Produk'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
              shape: const StadiumBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCatatanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Catatan tambahan'),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _catatanCtrl,
          maxLines: null,
          minLines: 3,
          style: AppText.body,
          decoration: InputDecoration(
            hintText: 'Ceritakan kondisi kulitmu hari ini...',
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
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _save,
        icon: const Icon(Icons.save_outlined, size: 18),
        label: const Text('Simpan Diary'),
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
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: AppText.cardTitle.copyWith(fontSize: 14),
    );
  }
}