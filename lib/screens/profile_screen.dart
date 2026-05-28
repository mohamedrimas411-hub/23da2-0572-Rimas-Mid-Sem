import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/services/auth_service.dart';
import '../core/services/database_service.dart';
import '../core/theme_manager.dart';
import '../core/localization_service.dart';
import '../core/services/biometric_service.dart';
import 'order_history_screen.dart';
import 'personal_info_screen.dart';
import 'shipping_address_screen.dart';
import 'payment_methods_screen.dart';
import 'settings_screen.dart';
import 'returns_screen.dart';
import 'track_order_screen.dart';
import 'reviews_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final DatabaseService databaseService = DatabaseService();
    final bool isDark = ThemeManager.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(LocalizationService().translate('profile'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: isDark ? Colors.white : Colors.black)),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                ],
              ),
              child: Icon(Icons.settings_outlined, size: 20, color: isDark ? Colors.white : Colors.black),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            StreamBuilder<Map<String, dynamic>?>(
              stream: databaseService.getUserProfile(authService.currentUser?.uid ?? ''),
              builder: (context, snapshot) {
                final name = snapshot.data?['name'] ?? LocalizationService().translate('user');
                final email = authService.currentUser?.email ?? 'rimas@gmail.com';
                return _buildProfileHeader(context, name, email);
              }
            ),
            const SizedBox(height: 40),
            _buildSettingsSection(context),
            const SizedBox(height: 30),
            _buildLogoutButton(context, authService),
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, String email) {
    final bool isDark = ThemeManager.isDarkMode;
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
                border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, width: 4),
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        Text(email, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewsScreen()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(140, 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(LocalizationService().translate('reviews'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final bool isDark = ThemeManager.isDarkMode;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(context, Icons.person_outline, LocalizationService().translate('personal_information'), () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalInfoScreen()));
          }),
          _buildDivider(),
          _buildSettingItem(context, Icons.location_on_outlined, LocalizationService().translate('shipping_address'), () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ShippingAddressScreen()));
          }),
          _buildDivider(),
          _buildSettingItem(context, Icons.payment_outlined, LocalizationService().translate('payment_methods'), () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()));
          }),
          _buildDivider(),
          _buildSettingItem(context, Icons.history, LocalizationService().translate('order_history'), () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderHistoryScreen()));
          }),
          _buildDivider(),
          _buildSettingItem(context, Icons.local_shipping_outlined, LocalizationService().translate('track_orders'), () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TrackOrderScreen()));
          }),
          _buildDivider(),
          _buildSettingItem(context, Icons.assignment_return_outlined, LocalizationService().translate('returns_refunds'), () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ReturnsScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    final bool isDark = ThemeManager.isDarkMode;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? Colors.black.withValues(alpha: 0.3) : AppColors.background,
          shape: BoxShape.circle
        ),
        child: Icon(icon, color: isDark ? AppColors.primary : Colors.black, size: 22),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isDark ? Colors.white : Colors.black)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1), indent: 70, endIndent: 20);
  }

  Widget _buildLogoutButton(BuildContext context, AuthService authService) {
    final bool isDark = ThemeManager.isDarkMode;
    final loc = LocalizationService();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutConfirmation(context, authService),
        icon: const Icon(Icons.logout, size: 20),
        label: Text(loc.translate('log_out'), style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF0F0F0),
          foregroundColor: isDark ? Colors.redAccent : Colors.black,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, AuthService authService) {
    final bool isDark = ThemeManager.isDarkMode;
    final loc = LocalizationService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          loc.translate('log_out'),
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await authService.signOut();
              await ThemeManager.reset();
              LocalizationService().reset();
              await BiometricService().reset();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
              }
            },
            child: const Text('Yes, Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

