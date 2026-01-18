import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/routing/router.dart';
import 'src/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MishkatApp(),
    ),
  );
}

class MishkatApp extends StatelessWidget {
  const MishkatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mishkat Learning',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
