import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/admin_login_screen.dart';
import 'screens/home_screen.dart';

class CanisOddMusicApp extends StatelessWidget {
  const CanisOddMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CANIS ODD MUSIC',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
      routes: {
        '/admin': (_) => const AdminLoginScreen(),
      },
    );
  }
}