import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/theme_manager.dart';

class ActiveDevicesScreen extends StatelessWidget {
  const ActiveDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeManager.isDarkMode;
    final Color textColor = isDark ? Colors.white : Colors.black;

    // Mock data for active devices
    final devices = [
      {'name': 'iPhone 15 Pro', 'location': 'Colombo, Sri Lanka', 'active': 'Current Device', 'icon': Icons.phone_iphone},
      {'name': 'MacBook Pro 14"', 'location': 'Kandy, Sri Lanka', 'active': 'Active 2 hours ago', 'icon': Icons.laptop_mac},
      {'name': 'iPad Pro', 'location': 'Colombo, Sri Lanka', 'active': 'Active 1 day ago', 'icon': Icons.tablet_mac},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Active Devices', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: devices.length,
        separatorBuilder: (context, index) => const Divider(height: 32),
        itemBuilder: (context, index) {
          final device = devices[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(device['icon'] as IconData, color: isDark ? Colors.white : Colors.black, size: 24),
            ),
            title: Text(device['name'] as String, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device['location'] as String, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  device['active'] as String, 
                  style: TextStyle(
                    color: device['active'] == 'Current Device' ? AppColors.primary : Colors.grey, 
                    fontSize: 11,
                    fontWeight: device['active'] == 'Current Device' ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            trailing: device['active'] != 'Current Device' 
              ? TextButton(
                  onPressed: () {},
                  child: const Text('Logout', style: TextStyle(color: Colors.red, fontSize: 12)),
                )
              : null,
          );
        },
      ),
    );
  }
}
