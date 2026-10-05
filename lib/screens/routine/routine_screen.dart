import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class RoutineScreen extends StatelessWidget {
  const RoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Routine Checker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checklist_outlined,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Fitur Routine Checker',
              style: AppText.sectionTitle.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: AppText.body.copyWith(
                color: AppColors.textDark.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}