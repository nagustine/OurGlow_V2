import 'enums.dart';

extension JenisKulitExt on JenisKulit {
  String get label {
    switch (this) {
      case JenisKulit.normal:
        return 'Normal';
      case JenisKulit.berminyak:
        return 'Berminyak';
      case JenisKulit.kering:
        return 'Kering';
      case JenisKulit.kombinasi:
        return 'Kombinasi';
      case JenisKulit.sensitif:
        return 'Sensitif';
      case JenisKulit.berjerawat:
        return 'Berjerawat';
    }
  }
}

extension WaktuPakaiExt on WaktuPakai {
  String get label {
    switch (this) {
      case WaktuPakai.pagi:
        return 'Pagi';
      case WaktuPakai.malam:
        return 'Malam';
      case WaktuPakai.pagiDanMalam:
        return 'Pagi & Malam';
    }
  }

  bool get isPagi =>
      this == WaktuPakai.pagi || this == WaktuPakai.pagiDanMalam;

  bool get isMalam =>
      this == WaktuPakai.malam || this == WaktuPakai.pagiDanMalam;
}

extension KategoriProdukExt on KategoriProduk {
  String get label {
    switch (this) {
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
}

extension StatusAmanExt on StatusAman {
  String get label {
    switch (this) {
      case StatusAman.aman:
        return 'Aman';
      case StatusAman.perluPerhatian:
        return 'Perlu Perhatian';
      case StatusAman.bentrok:
        return 'Bentrok';
    }
  }
}

extension KondisiKulitExt on KondisiKulit {
  String get label {
    switch (this) {
      case KondisiKulit.glowing:
        return 'Glowing';
      case KondisiKulit.normal:
        return 'Normal';
      case KondisiKulit.berminyak:
        return 'Berminyak';
      case KondisiKulit.kering:
        return 'Kering';
      case KondisiKulit.berjerawat:
        return 'Berjerawat';
      case KondisiKulit.iritasi:
        return 'Iritasi';
    }
  }
}