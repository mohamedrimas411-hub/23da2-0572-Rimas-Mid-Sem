import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'core/services/database_service.dart';
import 'core/services/auth_service.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/registration_screen.dart';

import 'core/theme_manager.dart';
import 'core/localization_service.dart';
import 'widgets/biometric_lock_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Auto-seed database if empty
  await DatabaseService().autoSeed();
  
  // Initialize Theme
  await ThemeManager.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BiometricLockWrapper(
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeManager.themeMode,
        builder: (context, mode, child) {
          return ListenableBuilder(
            listenable: LocalizationService(),
            builder: (context, child) {
              return MaterialApp(
                title: 'Zevix Clothing',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: mode,
                initialRoute: '/',
                routes: {
                  '/': (context) => const AuthWrapper(),
                  '/welcome': (context) => const WelcomeScreen(),
                  '/login': (context) => const LoginScreen(),
                  '/register': (context) => const RegistrationScreen(),
                  '/home': (context) => const HomeScreen(),
                  '/checkout': (context) => const CheckoutScreen(),
                },
              );
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const WelcomeScreen();
      },
    );
  }
}
