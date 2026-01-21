import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_theme.dart';
import '../../../core/localization/locale_provider.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    
    final languages = [
      {'name': 'English', 'code': 'en', 'flag': '🇺🇸'},
      {'name': 'Arabic', 'code': 'ar', 'flag': '🇸🇦'},
      {'name': 'Urdu', 'code': 'ur', 'flag': '🇵🇰'},
      {'name': 'Persian', 'code': 'fa', 'flag': '🇮🇷'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'App Language',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryNavy,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.secondaryNavy),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: languages.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final lang = languages[index];
          final isSelected = lang['code'] == currentLocale.languageCode;
          
          return ListTile(
            leading: Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
            title: Text(
              lang['name']!,
              style: GoogleFonts.inter(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.deepEmerald : AppTheme.secondaryNavy,
              ),
            ),
            trailing: isSelected 
                ? const Icon(Icons.check_circle, color: AppTheme.deepEmerald) 
                : null,
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(lang['code']!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Language changed to ${lang['name']}'),
                  backgroundColor: AppTheme.secondaryNavy,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
