import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/localization_service.dart';
import 'change_password_screen.dart';
import 'active_devices_screen.dart';
import '../core/services/biometric_service.dart';
import '../core/services/user_preference_service.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _twoFactor = false;
  bool _biometric = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await BiometricService().isEnabled();
    if (mounted) {
      setState(() => _biometric = enabled);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;

    final loc = LocalizationService();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.translate('security'), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSecurityItem(Icons.lock_outline, loc.translate('change_password'), loc.translate('change_password_desc'), isDark, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
          }),
          const Divider(height: 32),
          _buildToggleItem(Icons.vibration, loc.translate('two_factor_auth'), loc.translate('two_factor_auth_desc'), _twoFactor, isDark, (val) {
            setState(() => _twoFactor = val);
          }),
          const Divider(height: 32),
          _buildToggleItem(Icons.fingerprint, loc.translate('biometric_login'), loc.translate('biometric_login_desc'), _biometric, isDark, (val) {
            _handleBiometricToggle(val);
          }),
          const Divider(height: 32),
          _buildSecurityItem(Icons.devices, loc.translate('active_devices'), loc.translate('active_devices_desc'), isDark, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ActiveDevicesScreen()));
          }),
        ],
      ),
    );
  }

  Future<void> _handleBiometricToggle(bool val) async {
    if (val) {
      final service = BiometricService();
      final isAvailable = await service.isBiometricAvailable();
      if (!mounted) return;
      if (isAvailable) {
        final authenticated = await service.authenticate();
        if (!mounted) return;
        if (authenticated) {
          await service.setEnabled(true);
          await UserPreferenceService.syncToFirebase();
          setState(() => _biometric = true);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(LocalizationService().translate('biometric_enabled')), backgroundColor: Colors.green),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(LocalizationService().translate('auth_failed')), backgroundColor: Colors.red),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(LocalizationService().translate('biometrics_not_available')), backgroundColor: Colors.orange),
          );
        }
      }
    } else {
      await BiometricService().setEnabled(false);
      await UserPreferenceService.syncToFirebase();
      setState(() => _biometric = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocalizationService().translate('biometric_disabled'))),
        );
      }
    }
  }

  Widget _buildSecurityItem(IconData icon, String title, String subtitle, bool isDark, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: isDark ? Colors.white : Colors.black, size: 22),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildToggleItem(IconData icon, String title, String subtitle, bool value, bool isDark, ValueChanged<bool> onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: isDark ? Colors.white : Colors.black, size: 22),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}
