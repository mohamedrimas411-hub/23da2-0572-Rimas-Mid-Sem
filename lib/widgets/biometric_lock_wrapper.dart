import 'package:flutter/material.dart';
import '../core/services/biometric_service.dart';
import '../core/services/auth_service.dart';
import '../core/app_colors.dart';

class BiometricLockWrapper extends StatefulWidget {
  final Widget child;
  const BiometricLockWrapper({super.key, required this.child});

  @override
  State<BiometricLockWrapper> createState() => _BiometricLockWrapperState();
}

class _BiometricLockWrapperState extends State<BiometricLockWrapper> with WidgetsBindingObserver {
  final BiometricService _biometricService = BiometricService();
  final AuthService _authService = AuthService();
  bool _isLocked = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initial check on app start
    _checkAndLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Only authenticate if we are currently showing the lock screen
      if (_isLocked) {
        _authenticate();
      }
    } else if (state == AppLifecycleState.paused) {
      // App went to background, lock it if enabled
      _lockIfEnabled();
    }
  }

  Future<void> _lockIfEnabled() async {
    final enabled = await _biometricService.isEnabled();
    final isLoggedIn = _authService.currentUser != null;
    if (enabled && isLoggedIn) {
      setState(() {
        _isLocked = true;
      });
    }
  }

  Future<void> _checkAndLock() async {
    final enabled = await _biometricService.isEnabled();
    final isLoggedIn = _authService.currentUser != null;

    if (enabled && isLoggedIn) {
      setState(() => _isLocked = true);
      _authenticate();
    } else {
      setState(() => _isLocked = false);
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    
    setState(() => _isAuthenticating = true);
    
    final authenticated = await _biometricService.authenticate();
    
    if (authenticated) {
      setState(() {
        _isLocked = false;
        _isAuthenticating = false;
      });
    } else {
      setState(() => _isAuthenticating = false);
      // If authentication fails, we stay locked. 
      // The user can try again by clicking a button.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocked) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: AppColors.primary,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'ZEVIX SECURITY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Authentication Required',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  onPressed: _authenticate,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Unlock with Biometrics'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () async {
                    await _authService.signOut();
                    setState(() => _isLocked = false);
                  },
                  child: const Text(
                    'Logout instead',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
