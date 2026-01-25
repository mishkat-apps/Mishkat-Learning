import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'firebase_options.dart';
import 'src/core/routing/router.dart';
import 'src/core/theme/admin_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase for Web
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Remove the # from the URL
  usePathUrlStrategy();
  
  runApp(
    const ProviderScope(
      child: MishkatAdminApp(),
    ),
  );
}

class MishkatAdminApp extends ConsumerWidget {
  const MishkatAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Mishkat Admin Dashboard',
      theme: AdminTheme.theme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
