import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'fr';

  final List<Map<String, dynamic>> _languages = [
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷', 'locale': const Locale('fr')},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧', 'locale': const Locale('en')},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸', 'locale': const Locale('es')},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦', 'locale': const Locale('ar')},
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  void _loadSavedLanguage() async {
    // Récupérer la langue sauvegardée
    // Pour l'instant, on utilise 'fr' par défaut
  }

  void _changeLanguage(Locale locale, String code) {
    setState(() {
      _selectedLanguage = code;
    });
    // Changer la langue de l'application
    MyApp.setLocale(context, locale);
  }

  @override
  Widget build(BuildContext context) {
    // Récupérer les traductions avec gestion null
    AppLocalizations? t = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(t?.translate('language') ?? 'Langue'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E3A5F),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _languages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final lang = _languages[index];
          final isSelected = _selectedLanguage == lang['code'];
          
          return GestureDetector(
            onTap: () => _changeLanguage(lang['locale'], lang['code']),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFF1E3A5F) : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    lang['flag'],
                    style: const TextStyle(fontSize: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      lang['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFF1E3A5F) : Colors.black87,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.green, size: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}