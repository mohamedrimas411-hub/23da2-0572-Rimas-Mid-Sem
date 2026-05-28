import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/theme_manager.dart';
import '../core/localization_service.dart';
import '../core/services/user_preference_service.dart';
import 'personal_info_screen.dart';
import 'security_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeManager.isDarkMode;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final loc = LocalizationService();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.translate('settings'), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(loc.translate('account')),
            _buildSettingsItem(Icons.person_outline, loc.translate('personal_information'), null, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalInfoScreen()));
            }),
            _buildSettingsItem(Icons.security_outlined, loc.translate('security'), null, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityScreen()));
            }),
            _buildToggleItem(Icons.notifications_none_outlined, loc.translate('notifications'), _notifications, (val) {
              setState(() => _notifications = val);
            }),
            
            const SizedBox(height: 32),
            _buildSectionHeader(loc.translate('app_settings')),
            _buildToggleItem(Icons.dark_mode_outlined, loc.translate('dark_mode'), isDark, (val) {
              ThemeManager.toggleTheme(val);
              UserPreferenceService.syncToFirebase(); // Run in background
              if (mounted) setState(() {});
            }),
            _buildSettingsItem(Icons.language_outlined, loc.translate('language'), loc.currentLanguage, onTap: () => _showLanguageSelector(context)),
            _buildSettingsItem(Icons.payments_outlined, loc.translate('currency'), loc.currency, onTap: () => _showCurrencySelector(context)),
            
            const SizedBox(height: 32),
            _buildSectionHeader(loc.translate('support')),
            _buildSettingsItem(Icons.privacy_tip_outlined, loc.translate('privacy_policy'), null, onTap: () => _showPolicyDialog(context, loc.translate('privacy_policy'))),
            _buildSettingsItem(Icons.description_outlined, loc.translate('terms_of_service'), null, onTap: () => _showPolicyDialog(context, loc.translate('terms_of_service'))),
            _buildSettingsItem(Icons.info_outline, loc.translate('about_app'), null, onTap: () => _showAboutApp(context)),

            
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Version 1.0.2',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String? trailingText, {VoidCallback? onTap}) {
    final bool isDark = ThemeManager.isDarkMode;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isDark ? Colors.white70 : Colors.black, size: 24),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
        ],
      ),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildToggleItem(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    final bool isDark = ThemeManager.isDarkMode;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isDark ? Colors.white70 : Colors.black, size: 24),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final bool isDark = ThemeManager.isDarkMode;
    final loc = LocalizationService();
    final languages = ['English', 'Sinhala', 'Arabic', 'French', 'Spanish', 'German'];
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loc.translate('select_language'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 16),
            ...languages.map((lang) => ListTile(
              title: Text(lang, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              trailing: loc.currentLanguage == lang ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                Navigator.pop(context); // Instant feedback: close sheet first
                loc.setLanguage(lang);
                UserPreferenceService.syncToFirebase(); // Run in background
                if (mounted) setState(() {});
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showCurrencySelector(BuildContext context) {
    final bool isDark = ThemeManager.isDarkMode;
    final loc = LocalizationService();
    final Map<String, String> currencies = {
      'USD (\$)': 'USD',
      'LKR (Rs)': 'LKR',
      'EUR (€)': 'EUR',
      'GBP (£)': 'GBP',
      'JPY (¥)': 'JPY',
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loc.translate('select_currency'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 16),
            ...currencies.entries.map((entry) => ListTile(
              title: Text(entry.key, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              trailing: LocalizationService().currency == entry.value ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                Navigator.pop(context); // Instant feedback: close sheet first
                loc.setCurrency(entry.value);
                UserPreferenceService.syncToFirebase(); // Run in background
                if (mounted) setState(() {});
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showPolicyDialog(BuildContext context, String title) {
    final bool isDark = ThemeManager.isDarkMode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                IconButton(icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'This is a professional $title document for Zevix Clothing. We value your presence and security above all else.\n\n'
                  '1. We do not sell your personal data.\n'
                  '2. All card details are processed via secure channels.\n'
                  '3. Our platform is built for premium retail excellence.\n\n'
                  'By using this app, you agree to follow the standard guidelines of high-end digital commerce.\n\n'
                  'Our commitment to quality extends beyond our products to the legal framework that protects your shopping experience. We ensure that every transaction is encrypted and every customer interaction is handled with the utmost care.',
                  style: TextStyle(fontSize: 16, height: 1.6, color: isDark ? Colors.white70 : Colors.black.withValues(alpha: 0.7)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutApp(BuildContext context) {
    final bool isDark = ThemeManager.isDarkMode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('About Zevix', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                IconButton(icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(height: 32),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.shopping_bag, color: AppColors.primary, size: 48),
                  ),
                  const SizedBox(height: 16),
                  Text('Zevix Clothing', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  const Text('Version 1.0.2', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'Zevix is a premium e-commerce platform designed for modern fashion discovery. Developed with cutting-edge mobile technologies to provide a seamless shopping experience.\n\n'
                  'Our mission is to bridge the gap between high-end fashion and digital accessibility, ensuring every user feels the touch of luxury from their screen to their doorstep.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.6, color: isDark ? Colors.white70 : Colors.black.withValues(alpha: 0.7)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
