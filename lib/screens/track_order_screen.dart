import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/theme_manager.dart';
import '../core/localization_service.dart';

class TrackOrderScreen extends StatelessWidget {
  const TrackOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeManager.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(LocalizationService().translate('track_order')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                ],
              ),
              child: Column(
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${LocalizationService().translate('order_id')} #ORD_12345', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                        child: Text(LocalizationService().translate('in_transit'), style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                   const Divider(height: 32),
                  _buildTrackStep(context, LocalizationService().translate('order_placed'), 'May 12, 2026 - 10:30 AM', true, true),
                  _buildTrackStep(context, LocalizationService().translate('processing'), 'May 12, 2026 - 02:15 PM', true, true),
                  _buildTrackStep(context, LocalizationService().translate('shipped'), 'May 13, 2026 - 09:00 AM', true, false),
                  _buildTrackStep(context, LocalizationService().translate('in_transit'), 'May 14, 2026 - 08:45 AM', false, false),
                  _buildTrackStep(context, '${LocalizationService().translate('expected_by')} May 15', '', false, false, isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              LocalizationService().translate('delivery_address'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 12),
            Text(
              '123 Fashion Street, New York, NY 10001\nContact: +1 234 567 890',
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackStep(BuildContext context, String title, String subtitle, bool isCompleted, bool isActive, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primary : (isActive ? AppColors.primary.withValues(alpha: 0.2) : Colors.grey.shade300),
                shape: BoxShape.circle,
                border: isActive ? Border.all(color: AppColors.primary, width: 2) : null,
              ),
              child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? AppColors.primary : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCompleted || isActive ? (ThemeManager.isDarkMode ? Colors.white : Colors.black) : Colors.grey,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}
