import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'firebase_options.dart';
import 'src/core/services/migration_service.dart';
import 'src/core/routing/router.dart';
import 'src/theme/app_theme.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  if (kDebugMode) {
    // await MigrationService.migrateMockData(); // Seed data
  }

  usePathUrlStrategy();
  await dotenv.load(fileName: "assets/app_config.env");
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
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
    );
  }
}
