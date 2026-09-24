import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../models/enums.dart';

class StatusBadge extends StatelessWidget {
  final StatusAman status;
  final bool large;
  final String? customLabel;

  const StatusBadge({
    super.key,
    required this.status,
    this.large = false,
    this.customLabel,
  });

  Color get _color {
    switch (status) {
      case StatusAman.aman:
        return AppColors.statusSafe;
      case StatusAman.perluPerhatian:
        return AppColors.statusWarning;
      case StatusAman.bentrok:
        return AppColors.statusDanger;
    }
  }

  IconData get _icon {
    switch (status) {
      case StatusAman.aman:
        return Icons.check_circle;
      case StatusAman.perluPerhatian:
        return Icons.warning_amber_rounded;
      case StatusAman.bentrok:
        return Icons.error;
    }
  }

  String get _label {
    if (customLabel != null) return customLabel!;
    switch (status) {
      case StatusAman.aman:
        return 'Aman dipakai';
      case StatusAman.perluPerhatian:
        return 'Perlu perhatian';
      case StatusAman.bentrok:
        return 'Bentrok dengan produk lain';
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = large
        ? const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    final fontSize = large ? 15.0 : 12.0;
    final iconSize = large ? 22.0 : 16.0;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: Colors.white, size: iconSize),
          const SizedBox(width: 6),
          Text(
            _label,
            style: AppText.badge.copyWith(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}