import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'routine_product.dart';
import '../utils/product_icons.dart';

class RoutineProductCard extends StatelessWidget {
  final RoutineProduct product;
  final int urutan;
  final VoidCallback onDelete;

  const RoutineProductCard({
    super.key,
    required this.product,
    required this.urutan,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '$urutan',
              style: AppText.cardTitle.copyWith(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              ProductIcons.forKategori(product.kategori.name),
              size: 22,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nama,
                  style: AppText.body.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      product.kategori.name,
                      style: AppText.caption.copyWith(fontSize: 10),
                    ),
                    if (product.bahan.isNotEmpty) ...[
                      const Text(' • ',
                          style: TextStyle(fontSize: 10)),
                      Expanded(
                        child: Text(
                          product.bahan.take(2).join(', '),
                          style:
                              AppText.caption.copyWith(fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 18),
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
    );
  }
}