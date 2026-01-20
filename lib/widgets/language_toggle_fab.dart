import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:LaundryUp/generated/app_localizations.dart';
import '../main.dart';

class LanguageToggleFAB extends StatefulWidget {
  const LanguageToggleFAB({super.key});

  @override
  State<LanguageToggleFAB> createState() => _LanguageToggleFABState();
}

class _LanguageToggleFABState extends State<LanguageToggleFAB> {
  String _currentLang = 'id';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLang = prefs.getString('language') ?? 'id';
    });
  }

  Future<void> _toggleLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final newLang = _currentLang == 'id' ? 'en' : 'id';

    await prefs.setString('language', newLang);

    if (!mounted) return;

    setState(() {
      _currentLang = newLang;
    });

    // Update locale dynamically across the whole app
    LaundryApp.changeLocale(Locale(newLang));
  }

  @override
  Widget build(BuildContext context) {
    final isIndonesia = _currentLang == 'id';

    return FloatingActionButton(
      mini: true,
      onPressed: _toggleLanguage,
      backgroundColor: Colors.white,
      elevation: 4,
      tooltip: 'Ganti Bahasa / Change Language',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.language_rounded, color: Color(0xFF6366F1), size: 24),
          Positioned(
            right: 0,
            bottom: 0,
            child: Text(
              _currentLang.toUpperCase(),
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
            ),
          ),
        ],
      ),
    );
  }
}
