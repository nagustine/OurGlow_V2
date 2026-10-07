import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../models/diary_entry.dart';

class DiaryProductSheet extends StatefulWidget {
  final DiaryProduct? initial;

  const DiaryProductSheet({super.key, this.initial});

  @override
  State<DiaryProductSheet> createState() => _DiaryProductSheetState();
}

class _DiaryProductSheetState extends State<DiaryProductSheet> {
  int _step = 0;
  String _kategori = '';
  final Map<String, dynamic> _detail = {};
  late TextEditingController _namaCtrl;
  String _nama = '';

  static const List<Map<String, dynamic>> _kategoriList = [
  {'key': 'sunscreen', 'label': 'Sunscreen', 'icon': Icons.spa_outlined},
  {'key': 'serum', 'label': 'Serum', 'icon': Icons.spa_outlined},
  {'key': 'moisturizer', 'label': 'Moisturizer', 'icon': Icons.spa_outlined},
  {'key': 'cleanser', 'label': 'Cleanser', 'icon': Icons.spa_outlined},
  {'key': 'toner', 'label': 'Toner', 'icon': Icons.spa_outlined},
  {'key': 'lainnya', 'label': 'Lainnya', 'icon': Icons.spa_outlined},
];

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController();
    if (widget.initial != null) {
      _kategori = widget.initial!.kategori;
      _nama = widget.initial!.nama;
      _namaCtrl.text = widget.initial!.nama;
      _detail.addAll(widget.initial!.detail);
      _step = 2;
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 0 && _kategori.isEmpty) return;
    setState(() => _step++);
  }

  void _back() {
    if (_step == 0) {
      Navigator.pop(context);
    } else {
      setState(() => _step--);
    }
  }

  void _selesai() {
    if (_nama.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Isi nama produk dulu'),
          backgroundColor: AppColors.statusWarning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final result = DiaryProduct(
      nama: _nama.trim(),
      kategori: _kategori,
      detail: Map<String, dynamic>.from(_detail),
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.neutral,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  if (_step > 0)
                    IconButton(
                      onPressed: _back,
                      icon: const Icon(Icons.arrow_back),
                      color: AppColors.primary,
                    ),
                  Text(
                    _step == 0
                        ? 'Pilih Kategori Produk'
                        : _step == 1
                            ? 'Detail Produk'
                            : 'Konfirmasi',
                    style: AppText.cardTitle.copyWith(fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (_step == 0) _buildStepKategori(),
              if (_step == 1) _buildStepDetail(),
              if (_step == 2) _buildStepKonfirmasi(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepKategori() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _kategoriList.map((k) {
        final active = _kategori == k['key'];
        return GestureDetector(
          onTap: () {
            setState(() => _kategori = k['key'] as String);
            _next();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  k['icon'] as IconData,
                  size: 18,
                  color: active ? Colors.white : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  k['label'] as String,
                  style: AppText.badge.copyWith(
                    color: active ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Nama produk'),
        TextField(
          controller: _namaCtrl,
          onChanged: (v) => _nama = v,
          style: AppText.body,
          decoration: _inputDecoration('Contoh: Sunscreen SPF 50'),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_kategori == 'sunscreen') ..._sunscreenFields(),
        if (_kategori == 'serum') ..._serumFields(),
        if (_kategori == 'moisturizer') ..._moisturizerFields(),
        if (_kategori == 'cleanser') ..._cleanserFields(),
        if (_kategori == 'toner') ..._tonerFields(),
        if (_kategori == 'lainnya') ..._lainnyaFields(),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              if (_namaCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Isi nama produk dulu'),
                    backgroundColor: AppColors.statusWarning,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              _nama = _namaCtrl.text.trim();
              _next();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            child: const Text('Lanjut'),
          ),
        ),
      ],
    );
  }

  List<Widget> _sunscreenFields() {
    return [
      _label('Jenis SPF'),
      _chipGroup('spf', ['SPF 30', 'SPF 50', 'SPF 50+']),
      const SizedBox(height: AppSpacing.md),
      _label('PA Level'),
      _chipGroup('pa', ['PA+', 'PA++', 'PA+++', 'PA++++']),
      const SizedBox(height: AppSpacing.md),
      _label('Tekstur'),
      _chipGroup('tekstur', ['Cream', 'Gel', 'Lotion', 'Stick', 'Spray']),
      const SizedBox(height: AppSpacing.md),
      _label('Kapan digunakan'),
      _chipGroup('waktu', ['Pagi', 'Siang / reapply', 'Sore']),
    ];
  }

  List<Widget> _serumFields() {
    return [
      _label('Kandungan utama'),
      _chipGroup('kandungan', [
        'Niacinamide',
        'Vitamin C',
        'Hyaluronic Acid',
        'Salicylic Acid',
        'Retinol',
        'Alpha Arbutin',
        'Lainnya',
      ]),
      const SizedBox(height: AppSpacing.md),
      _label('Tujuan penggunaan'),
      _chipGroup('tujuan', [
        'Hydrating',
        'Brightening',
        'Acne Care',
        'Anti-Aging',
        'Skin Barrier',
      ]),
    ];
  }

  List<Widget> _moisturizerFields() {
    return [
      _label('Tipe moisturizer'),
      _chipGroup('tipe', ['Gel', 'Cream', 'Lotion', 'Balm']),
      const SizedBox(height: AppSpacing.md),
      _label('Fokus'),
      _chipGroup('fokus', [
        'Hydration',
        'Skin Barrier',
        'Soothing',
        'Brightening',
      ]),
    ];
  }

  List<Widget> _cleanserFields() {
    return [
      _label('Jenis'),
      _chipGroup('jenis', ['Gel', 'Foam', 'Cream', 'Oil/Balm']),
      const SizedBox(height: AppSpacing.md),
      _label('Fokus'),
      _chipGroup('fokus', [
        'Gentle',
        'Hydrating',
        'Acne Care',
        'Exfoliating',
      ]),
    ];
  }

  List<Widget> _tonerFields() {
    return [
      _label('Jenis'),
      _chipGroup('jenis', ['Hydrating', 'Exfoliating', 'Soothing']),
      const SizedBox(height: AppSpacing.md),
      _label('Kandungan utama'),
      _chipGroup('kandungan', [
        'Hyaluronic Acid',
        'AHA/BHA',
        'Centella',
        'Niacinamide',
      ]),
    ];
  }

  List<Widget> _lainnyaFields() {
    return [
      _label('Keterangan'),
      TextField(
        onChanged: (v) => _detail['keterangan'] = v,
        maxLines: 3,
        decoration: _inputDecoration('Tulis keterangan produk'),
      ),
    ];
  }

  Widget _buildStepKonfirmasi() {
    final kategori = _kategoriList.firstWhere(
      (k) => k['key'] == _kategori,
      orElse: () => _kategoriList.last,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.small),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    kategori['icon'] as IconData,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    kategori['label'] as String,
                    style: AppText.badge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _nama.isEmpty ? '(belum diisi)' : _nama,
                style: AppText.cardTitle.copyWith(fontSize: 15),
              ),
              if (_detail.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 6),
                ..._detail.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            _labelize(e.key),
                            style: AppText.caption.copyWith(fontSize: 11),
                          ),
                        ),
                        const Text(': '),
                        Expanded(
                          child: Text(
                            e.value.toString(),
                            style: AppText.bodySmall.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _selesai,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            child: const Text('Tambahkan Produk'),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppText.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _chipGroup(String key, List<String> options) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final active = _detail[key] == opt;
        return GestureDetector(
          onTap: () {
            setState(() {
              if (active) {
                _detail.remove(key);
              } else {
                _detail[key] = opt;
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              opt,
              style: AppText.badge.copyWith(
                fontSize: 12,
                color: active ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppText.body.copyWith(
        color: AppColors.textDark.withValues(alpha: 0.4),
      ),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
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
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
    );
  }

  String _labelize(String key) {
    if (key.isEmpty) return key;
    return '${key[0].toUpperCase()}${key.substring(1)}';
  }
}