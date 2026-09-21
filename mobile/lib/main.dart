import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'services/auth_service.dart';
import 'services/locale_service.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().init();
  await ThemeService().init();
  await LocaleService().init();
  runApp(const UniverSuperApp());
}

class UniverSuperApp extends StatelessWidget {
  const UniverSuperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        AuthService(),
        ThemeService(),
        LocaleService(),
      ]),
      builder: (context, _) {
        final isAuthenticated = AuthService().isAuthenticated;

        return MaterialApp(
          title: 'UNIVER SuperApp',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeService().themeMode,
          home: isAuthenticated ? const MainShell() : const LoginScreen(),
        );
      },
    );
  }
}

