import '../localization_service.dart';
import '../theme_manager.dart';
import 'biometric_service.dart';
import 'database_service.dart';
import 'auth_service.dart';
import 'package:flutter/foundation.dart';

class UserPreferenceService {
  static final DatabaseService _db = DatabaseService();
  static final AuthService _auth = AuthService();

  /// Syncs current local preferences to Firebase Firestore for the logged-in user.
  static Future<void> syncToFirebase() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final data = {
        'preferences': {
          'language': LocalizationService().currentLanguage,
          'currency': LocalizationService().currency,
          'isDarkMode': ThemeManager.isDarkMode,
          'biometricEnabled': await BiometricService().isEnabled(),
        }
      };

      await _db.updateUserProfile(user.uid, data);
      debugPrint('Preferences synced to Firebase successfully.');
    } catch (e) {
      debugPrint('Error syncing preferences to Firebase: $e');
    }
  }

  /// Fetches preferences from Firebase and applies them to the local services.
  static Future<void> fetchAndApply() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Using get().first instead of stream for a one-time fetch during login
      final profileSnapshot = await _db.getUserProfile(user.uid).first;
      
      if (profileSnapshot != null && profileSnapshot.containsKey('preferences')) {
        final prefs = profileSnapshot['preferences'] as Map<String, dynamic>;
        
        if (prefs['language'] != null) {
          LocalizationService().setLanguage(prefs['language']);
        }
        if (prefs['currency'] != null) {
          LocalizationService().setCurrency(prefs['currency']);
        }
        if (prefs['isDarkMode'] != null) {
          await ThemeManager.toggleTheme(prefs['isDarkMode']);
        }
        if (prefs['biometricEnabled'] != null) {
          await BiometricService().setEnabled(prefs['biometricEnabled']);
        }
        debugPrint('Preferences fetched and applied from Firebase.');
      }
    } catch (e) {
      debugPrint('Error fetching preferences from Firebase: $e');
    }
  }
}
