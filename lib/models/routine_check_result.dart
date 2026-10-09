import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Status hasil analisis Routine Checker.
enum RoutineCheckStatus {
  cocok,
  perluPerhatian,
  potensiKonflik,
  dataBelumCukup,
}

/// Model hasil analisis kecocokan rutinitas skincare.
///
/// Catatan: `score` dibuat nullable supaya sistem dapat mengembalikan
/// hasil "data belum cukup" tanpa memaksakan angka yang seolah-olah akurat.
class RoutineCheckResult {
  /// Skor 0-100. `null` jika data belum cukup untuk dinilai.
  final double? score;

  /// Status keseluruhan hasil analisis.
  final RoutineCheckStatus status;

  /// Daftar peringatan (misal potensi konflik bahan).
  final List<String> warnings;

  /// Daftar rekomendasi untuk pengguna.
  final List<String> recommendations;

  /// Apakah data produk cukup lengkap untuk dianalisis.
  final bool dataComplete;

  /// Jumlah pasangan produk yang aman berdasarkan aturan yang tersedia.
  final int safeCount;

  /// Jumlah temuan yang perlu perhatian.
  final int warningCount;

  /// Jumlah potensi konflik bahan.
  final int conflictCount;

  const RoutineCheckResult({
    required this.score,
    required this.status,
    required this.warnings,
    required this.recommendations,
    required this.dataComplete,
    this.safeCount = 0,
    this.warningCount = 0,
    this.conflictCount = 0,
  });

  /// Hasil default ketika belum ada analisis yang dijalankan.
  factory RoutineCheckResult.empty() => const RoutineCheckResult(
        score: null,
        status: RoutineCheckStatus.dataBelumCukup,
        warnings: [],
        recommendations: [],
        dataComplete: false,
      );

  /// Label status dalam Bahasa Indonesia.
  String get statusLabel {
    switch (status) {
      case RoutineCheckStatus.cocok:
        return 'Cocok berdasarkan aturan yang tersedia';
      case RoutineCheckStatus.perluPerhatian:
        return 'Perlu perhatian';
      case RoutineCheckStatus.potensiKonflik:
        return 'Potensi konflik';
      case RoutineCheckStatus.dataBelumCukup:
        return 'Data belum cukup';
    }
  }

  /// Deskripsi singkat status.
  String get statusDescription {
    switch (status) {
      case RoutineCheckStatus.cocok:
        return 'Tidak ada konflik yang terdeteksi dari aturan yang tersedia.';
      case RoutineCheckStatus.perluPerhatian:
        return 'Ada kombinasi yang perlu diperiksa lebih lanjut sebelum digunakan bersamaan.';
      case RoutineCheckStatus.potensiKonflik:
        return 'Terdapat potensi konflik bahan yang sebaiknya dihindari.';
      case RoutineCheckStatus.dataBelumCukup:
        return 'Lengkapi data produk untuk mendapatkan analisis yang memadai.';
    }
  }

  /// Warna yang merepresentasikan status.
  Color get statusColor {
    switch (status) {
      case RoutineCheckStatus.cocok:
        return AppColors.statusSafe;
      case RoutineCheckStatus.perluPerhatian:
        return AppColors.statusWarning;
      case RoutineCheckStatus.potensiKonflik:
        return AppColors.statusDanger;
      case RoutineCheckStatus.dataBelumCukup:
        return AppColors.neutral;
    }
  }

  /// Icon yang merepresentasikan status.
  IconData get statusIcon {
    switch (status) {
      case RoutineCheckStatus.cocok:
        return Icons.check_circle_outline;
      case RoutineCheckStatus.perluPerhatian:
        return Icons.info_outline;
      case RoutineCheckStatus.potensiKonflik:
        return Icons.warning_amber_rounded;
      case RoutineCheckStatus.dataBelumCukup:
        return Icons.hourglass_empty;
    }
  }
}