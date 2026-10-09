import 'package:flutter/material.dart';

class ProductIcons {
  ProductIcons._();

  static const IconData defaultIcon = Icons.spa_outlined;

  static const Map<String, IconData> _icons = {
    'sunscreen': Icons.wb_sunny_outlined,
    'serum': Icons.science_outlined,
    'moisturizer': Icons.water_drop_outlined,
    'cleanser': Icons.cleaning_services_outlined,
    'toner': Icons.local_drink_outlined,
    'exfoliator': Icons.auto_fix_high_outlined,
    'masker': Icons.face_retouching_natural_outlined,
    'lainnya': Icons.spa_outlined,
  };

  static IconData forKategori(String kategori) {
    final key = kategori.toLowerCase().trim();
    return _icons[key] ?? defaultIcon;
  }

  static IconData forNama(String nama) {
    final n = nama.toLowerCase();
    if (n.contains('sunscreen') || n.contains('spf')) {
      return _icons['sunscreen']!;
    }
    if (n.contains('serum')) return _icons['serum']!;
    if (n.contains('moisturizer') || n.contains('pelembap')) {
      return _icons['moisturizer']!;
    }
    if (n.contains('cleanser') || n.contains('facial wash')) {
      return _icons['cleanser']!;
    }
    if (n.contains('toner')) return _icons['toner']!;
    if (n.contains('exfoliator') || n.contains('exfoliat')) {
      return _icons['exfoliator']!;
    }
    if (n.contains('mask') || n.contains('masker')) {
      return _icons['masker']!;
    }
    return defaultIcon;
  }

  static List<Map<String, dynamic>> get allKategori => const [
        {'key': 'sunscreen', 'label': 'Sunscreen'},
        {'key': 'serum', 'label': 'Serum'},
        {'key': 'moisturizer', 'label': 'Moisturizer'},
        {'key': 'cleanser', 'label': 'Cleanser'},
        {'key': 'toner', 'label': 'Toner'},
        {'key': 'lainnya', 'label': 'Lainnya'},
      ];
}