import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'src/core/routing/router.dart';
import 'src/theme/app_theme.dart';
import 'src/core/localization/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final container = ProviderContainer();
  await container.read(localeProvider.notifier).init();

  usePathUrlStrategy();
  await dotenv.load(fileName: "assets/app_config.env");
  
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MishkatApp(),
    ),
  );
}

class MishkatApp extends ConsumerWidget {
  const MishkatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    
    return MaterialApp.router(
      title: 'Mishkat Learning',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: ref.watch(goRouterProvider),
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('ur'),
        Locale('fa'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
