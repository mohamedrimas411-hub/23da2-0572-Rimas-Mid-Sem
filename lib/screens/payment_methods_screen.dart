import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../core/services/auth_service.dart';
import '../core/services/database_service.dart';
import '../core/localization_service.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();
  List<dynamic> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final profile = await _db.getUserProfile(user.uid).first;
      if (profile != null) {
        setState(() {
          _cards = profile['paymentMethods'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addCard(Map<String, dynamic> newCard) async {
    final user = _auth.currentUser;
    if (user != null) {
      final updatedCards = List.from(_cards)..add(newCard);
      await _db.updateUserProfile(user.uid, {'paymentMethods': updatedCards});
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(LocalizationService().translate('payment_methods'), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(LocalizationService().translate('your_saved_cards'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextButton.icon(
                        onPressed: _showAddCardDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(LocalizationService().translate('add_new')),
                        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_cards.isEmpty)
                    _buildEmptyState()
                  else
                    ..._cards.map((card) => _buildCardWidget(card)),
                  const SizedBox(height: 32),
                  Text(LocalizationService().translate('payment_security'), style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.security, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(LocalizationService().translate('security_desc'), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  void _showAddCardDialog() {
    final loc = LocalizationService();
    String cardType = loc.translate('visa');
    final numberController = TextEditingController();
    final nameController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();

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
                Text(loc.translate('add_new_card'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),

                // Card Type Selection
                Text(loc.translate('select_card_provider'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTypeChip(loc.translate('visa'), Icons.credit_card, cardType == loc.translate('visa'), () => setModalState(() => cardType = loc.translate('visa'))),
                      const SizedBox(width: 12),
                      _buildTypeChip(loc.translate('mastercard'), Icons.credit_card, cardType == loc.translate('mastercard'), () => setModalState(() => cardType = loc.translate('mastercard'))),
                      const SizedBox(width: 12),
                      _buildTypeChip(loc.translate('amex'), Icons.credit_card, cardType == loc.translate('amex'), () => setModalState(() => cardType = loc.translate('amex'))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _buildDialogField(
                  numberController, 
                  loc.translate('card_number'), 
                  Icons.credit_card_outlined, 
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, CardNumberFormatter()],
                  maxLength: 19,
                ),
                const SizedBox(height: 16),
                _buildDialogField(nameController, loc.translate('cardholder_name'), Icons.person_outline),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDialogField(
                        expiryController, 
                        loc.translate('expiry_date'), 
                        Icons.calendar_today_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, ExpiryDateFormatter()],
                        maxLength: 5,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDialogField(
                        cvvController, 
                        loc.translate('cvv'), 
                        Icons.lock_outline, 
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      if (numberController.text.length >= 19 && nameController.text.isNotEmpty) {
                        final rawNumber = numberController.text.replaceAll(' ', '');
                        
                        _addCard({
                          'lastFour': rawNumber.substring(rawNumber.length - 4),
                          'cardholderName': nameController.text.trim(),
                          'expiry': expiryController.text.trim(),
                          'type': cardType,
                        });
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                    child: Text(loc.translate('save_card'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildTypeChip(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          Icon(Icons.add_card_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(LocalizationService().translate('no_cards'), style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCardWidget(Map<String, dynamic> card) {
    final type = card['type'] ?? 'Visa';
    final isVisa = type == 'Visa';
    final isAmex = type == 'Amex';
    final isMastercard = type == 'Mastercard';

    List<Color> colors = [const Color(0xFF222222), const Color(0xFF111111)]; // Default Titanium
    if (isVisa) colors = [const Color(0xFF1A1F71), const Color(0xFF0038A8)]; // Visa Blue
    if (isAmex) colors = [const Color(0xFF0070D2), const Color(0xFF003F72)]; // Amex Blue

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: colors.last.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background elements for premium feel
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fake EMV Chip
                  Container(
                    width: 44,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.amber.shade200,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.amber.shade400, width: 1),
                    ),
                    child: Stack(
                      children: [
                        Positioned(left: 10, top: 0, bottom: 0, child: Container(width: 1, color: Colors.amber.shade400)),
                        Positioned(right: 10, top: 0, bottom: 0, child: Container(width: 1, color: Colors.amber.shade400)),
                        Positioned(top: 10, left: 0, right: 0, child: Container(height: 1, color: Colors.amber.shade400)),
                        Positioned(bottom: 10, left: 0, right: 0, child: Container(height: 1, color: Colors.amber.shade400)),
                      ],
                    ),
                  ),
                  // Logo based on type
                  if (isVisa)
                    const Text('VISA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24, fontStyle: FontStyle.italic, letterSpacing: 1))
                  else if (isAmex)
                    const Text('AMEX', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 1))
                  else if (isMastercard)
                    Row(
                      children: [
                        Container(width: 16, height: 16, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red.withValues(alpha: 0.8))),
                        Transform.translate(offset: const Offset(-6, 0), child: Container(width: 16, height: 16, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.orange.withValues(alpha: 0.8)))),
                      ],
                    )
                  else
                    const Icon(Icons.credit_card, color: Colors.white, size: 32),
                ],
              ),
              const SizedBox(height: 8),
              Text('••••  ••••  ••••  ${card['lastFour']}', style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 3, fontFamily: 'monospace', fontWeight: FontWeight.w600)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(LocalizationService().translate('cardholder'), style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text(card['cardholderName']?.toUpperCase() ?? 'USER NAME', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(LocalizationService().translate('expires'), style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text(card['expiry'] ?? '00/00', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String hint, IconData icon, {TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters, int? maxLength}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      style: const TextStyle(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        counterText: '',
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

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    
    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != text.length && nonZeroIndex < 4) {
        buffer.write('/');
      }
    }
    
    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}
