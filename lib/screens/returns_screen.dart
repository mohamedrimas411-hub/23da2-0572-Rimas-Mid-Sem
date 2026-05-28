import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/theme_manager.dart';
import '../core/localization_service.dart';

class ReturnsScreen extends StatelessWidget {
  const ReturnsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeManager.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(LocalizationService().translate('returns_refunds')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              context,
              LocalizationService().translate('how_to_return'),
              LocalizationService().translate('return_policy_desc'),
              Icons.assignment_return_outlined,
            ),
            const SizedBox(height: 24),
            Text(
              LocalizationService().translate('active_returns'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildEmptyState(context),
            const SizedBox(height: 32),
            Text(
              LocalizationService().translate('refund_status'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildRefundItem(context, 'ORD_7721', 'Completed', '\$120.00', 'May 10, 2026'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String desc, IconData icon) {
    final bool isDark = ThemeManager.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final bool isDark = ThemeManager.isDarkMode;
    return Center(
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(LocalizationService().translate('no_returns'), style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildRefundItem(BuildContext context, String orderId, String status, String amount, String date) {
    final bool isDark = ThemeManager.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${LocalizationService().translate('order_id')} #$orderId', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              Text(LocalizationService().translate(status.toLowerCase()), style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
