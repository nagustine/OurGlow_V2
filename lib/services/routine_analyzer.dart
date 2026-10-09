import '../models/routine_product.dart';
import '../models/routine_check_result.dart';
import '../models/enums.dart';
import 'service_locator.dart';

class RoutineAnalyzer {
  RoutineAnalyzer._();

  static Future<RoutineCheckResult> analyze(
    List<RoutineProduct> products,
  ) async {
    if (products.isEmpty) return RoutineCheckResult.empty();

    await ServiceLocator.ingredients.load();

    final warnings = <String>[];
    final recommendations = <String>[];
    int conflictCount = 0;
    int warningCount = 0;
    int safeCount = 0;

    final withoutBahan = products.where((p) => p.bahan.isEmpty).toList();
    final dataComplete = withoutBahan.isEmpty;

    for (var i = 0; i < products.length; i++) {
      for (var j = i + 1; j < products.length; j++) {
        final a = products[i];
        final b = products[j];

        if (a.waktuPakai != b.waktuPakai &&
            a.waktuPakai != WaktuPakai.pagiDanMalam &&
            b.waktuPakai != WaktuPakai.pagiDanMalam) {
          continue;
        }

        final conflictsAB = ServiceLocator.ingredients.checkConflicts([
          ...a.bahan,
          ...b.bahan,
        ]);

        bool foundForPair = false;

        for (final c in conflictsAB) {
          final aHasA = a.bahan.contains(c.ingredientA.id);
          final aHasB = a.bahan.contains(c.ingredientB.id);
          final bHasA = b.bahan.contains(c.ingredientA.id);
          final bHasB = b.bahan.contains(c.ingredientB.id);

          final aHas = aHasA || aHasB;
          final bHas = bHasA || bHasB;
          if (!(aHas && bHas)) continue;

          foundForPair = true;

          if (c.severity == StatusAman.bentrok) {
            conflictCount++;
            warnings.add(
              '${a.nama} + ${b.nama}: ${c.ingredientA.name} + '
              '${c.ingredientB.name} — berpotensi konflik.',
            );
          } else {
            warningCount++;
            warnings.add(
              '${a.nama} + ${b.nama}: ${c.ingredientA.name} + '
              '${c.ingredientB.name} — perlu perhatian.',
            );
          }
        }

        if (!foundForPair) safeCount++;
      }
    }

    final pagiProducts = products.where(
      (p) =>
          p.waktuPakai == WaktuPakai.pagi ||
          p.waktuPakai == WaktuPakai.pagiDanMalam,
    );
    final hasSunscreen =
        pagiProducts.any((p) => p.kategori == KategoriProduk.sunscreen);
    if (pagiProducts.isNotEmpty && !hasSunscreen) {
      recommendations.add('Tambahkan sunscreen untuk rutinitas pagi.');
    }

    if (!dataComplete) {
      recommendations.add(
        'Lengkapi data bahan pada ${withoutBahan.length} produk '
        'agar analisis lebih akurat.',
      );
    }

    final sorted = [...products]..sort((a, b) => a.urutan.compareTo(b.urutan));
    if (sorted.isNotEmpty && sorted.first.kategori != KategoriProduk.cleanser) {
      recommendations.add(
        'Produk pertama sebaiknya cleanser, bukan '
        '${sorted.first.kategori.name}.',
      );
    }

    if (conflictCount == 0 && warningCount == 0 && dataComplete) {
      recommendations.add(
        'Tidak ada konflik bahan yang terdeteksi. Pertahankan rutinitas ini.',
      );
    }

    double? score;
    if (dataComplete) {
      score = 100 - (warningCount * 8) - (conflictCount * 15);
      if (score < 0) score = 0;
      if (score > 100) score = 100;
    }

    RoutineCheckStatus status;
    if (!dataComplete) {
      status = RoutineCheckStatus.dataBelumCukup;
    } else if (conflictCount > 0) {
      status = RoutineCheckStatus.potensiKonflik;
    } else if (warningCount > 0) {
      status = RoutineCheckStatus.perluPerhatian;
    } else {
      status = RoutineCheckStatus.cocok;
    }

    return RoutineCheckResult(
      score: score,
      status: status,
      warnings: warnings,
      recommendations: recommendations,
      dataComplete: dataComplete,
      safeCount: safeCount,
      warningCount: warningCount,
      conflictCount: conflictCount,
    );
  }

  static Future<RoutineCheckResult> analyzeManual(
    List<String> ingredientIds,
  ) async {
    if (ingredientIds.isEmpty) {
      return RoutineCheckResult.empty();
    }

    await ServiceLocator.ingredients.load();

    final ids = ingredientIds.toSet().toList();

    final conflicts = ServiceLocator.ingredients.checkConflicts(ids);
    final warnings = <String>[];
    int conflictCount = 0;
    int warningCount = 0;

    for (final c in conflicts) {
      if (c.severity == StatusAman.bentrok) {
        conflictCount++;
        warnings.add(
          '${c.ingredientA.name} + ${c.ingredientB.name} — '
          'berpotensi konflik.',
        );
      } else {
        warningCount++;
        warnings.add(
          '${c.ingredientA.name} + ${c.ingredientB.name} — '
          'perlu perhatian.',
        );
      }
    }

    final recommendations = <String>[];
    if (conflictCount > 0) {
      recommendations.add(
        'Pisahkan waktu pemakaian bahan yang berkonflik atau '
        'kurangi frekuensinya.',
      );
    }
    if (warningCount > 0) {
      recommendations.add(
        'Pantau toleransi kulit saat menggunakan kombinasi ini.',
      );
    }
    if (conflictCount == 0 && warningCount == 0) {
      recommendations.add(
        'Kombinasi bahan ini umumnya aman berdasarkan aturan yang tersedia.',
      );
    }

    double score = 100 - (warningCount * 8) - (conflictCount * 15);
    if (score < 0) score = 0;
    if (score > 100) score = 100;

    RoutineCheckStatus status;
    if (conflictCount > 0) {
      status = RoutineCheckStatus.potensiKonflik;
    } else if (warningCount > 0) {
      status = RoutineCheckStatus.perluPerhatian;
    } else {
      status = RoutineCheckStatus.cocok;
    }

    return RoutineCheckResult(
      score: score,
      status: status,
      warnings: warnings,
      recommendations: recommendations,
      dataComplete: true,
      safeCount: ids.length - warnings.length,
      warningCount: warningCount,
      conflictCount: conflictCount,
    );
  }
}