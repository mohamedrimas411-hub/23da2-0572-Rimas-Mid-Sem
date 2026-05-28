import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/services/auth_service.dart';
import '../core/services/database_service.dart';
import '../core/localization_service.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();
  List<dynamic> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final user = _auth.currentUser;
    if (user != null) {
      final profile = await _db.getUserProfile(user.uid).first;
      if (profile != null && profile['addresses'] != null) {
        setState(() {
          _addresses = profile['addresses'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addAddress(Map<String, dynamic> newAddress) async {
    final user = _auth.currentUser;
    if (user != null) {
      final updatedAddresses = List.from(_addresses)..add(newAddress);
      await _db.updateUserProfile(user.uid, {'addresses': updatedAddresses});
      _loadAddresses();
    }
  }

  void _showAddAddressDialog() {
    final loc = LocalizationService();
    String label = loc.translate('home_label');
    final cityController = TextEditingController();
    final streetController = TextEditingController();
    final landmarkController = TextEditingController();
    final zipController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 24),
                const SizedBox(height: 24),
                Text(loc.translate('add_new_address'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                
                // Label selection (Home / Office)
                Row(
                  children: [
                    _buildLabelChip(loc.translate('home_label'), Icons.home_outlined, label == loc.translate('home_label'), () => setModalState(() => label = loc.translate('home_label'))),
                    const SizedBox(width: 12),
                    _buildLabelChip(loc.translate('office_label'), Icons.work_outline, label == loc.translate('office_label'), () => setModalState(() => label = loc.translate('office_label'))),
                  ],
                ),
                const SizedBox(height: 24),
                
                _buildDialogField(cityController, loc.translate('region_city_district'), Icons.map_outlined),
                const SizedBox(height: 16),
                _buildDialogField(streetController, loc.translate('street_address'), Icons.location_on_outlined),
                const SizedBox(height: 16),
                _buildDialogField(landmarkController, loc.translate('landmark_optional'), Icons.flag_outlined),
                const SizedBox(height: 16),
                _buildDialogField(zipController, loc.translate('postal_code'), Icons.pin_drop_outlined, keyboardType: TextInputType.number),
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      if (streetController.text.isNotEmpty && cityController.text.isNotEmpty) {
                        _addAddress({
                          'label': label,
                          'street': streetController.text.trim(),
                          'city': cityController.text.trim(),
                          'zip': zipController.text.trim(),
                          'landmark': landmarkController.text.trim(),
                          'isDefault': _addresses.isEmpty,
                        });
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 0,
                    ),
                    child: Text(loc.translate('save_address'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabelChip(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 18),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(LocalizationService().translate('shipping_address'), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) => _buildAddressCard(_addresses[index]),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAddressDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(LocalizationService().translate('add_new'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(LocalizationService().translate('no_addresses'), style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address) {
    final bool isDefault = address['isDefault'] ?? false;
    final loc = LocalizationService();
    final String label = address['label'] ?? loc.translate('home_label');
    final IconData icon = (label == 'Home' || label == loc.translate('home_label')) ? Icons.home_outlined : Icons.work_outline;

    return GestureDetector(
      onTap: () {
        final fullAddress = "${address['street']}, ${address['city']}, ${address['zip']}";
        Navigator.pop(context, fullAddress);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isDefault ? Border.all(color: AppColors.primary, width: 2) : null,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      if (isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(loc.translate('default_label'), style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(address['street'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  if (address['landmark'] != null && address['landmark'].toString().isNotEmpty)
                    Text('${loc.translate('near')} ${address['landmark']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  Text('${address['city']}, ${address['zip']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String hint, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }
}
