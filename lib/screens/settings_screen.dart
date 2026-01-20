import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:LaundryUp/generated/app_localizations.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentLanguage = 'id';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = prefs.getString('language') ?? 'id';
    });
  }

  Future<void> _changeLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);

    if (!mounted) return;

    setState(() {
      _currentLanguage = langCode;
    });

    // Update locale dynamically
    LaundryApp.changeLocale(Locale(langCode));
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_role');
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildSettingsSection(
            title: "Bahasa",
            children: [
              _buildLanguageItem("Bahasa Indonesia", 'id', theme),
              _buildLanguageItem("English", 'en', theme),
            ],
            theme: theme,
          ),
          const SizedBox(height: 32),
          _buildSettingsSection(
            title: "Akun",
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                ),
                title: Text(l10n.logout, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.logout),
                      content: const Text("Apakah Anda yakin ingin keluar dari akun?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                        TextButton(onPressed: _logout, child: const Text("Keluar", style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                },
              ),
            ],
            theme: theme,
          ),
          const SizedBox(height: 48),
          Center(
            child: Text(
              "LaundryUp v1.0.0",
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({required String title, required List<Widget> children, required ThemeData theme}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageItem(String name, String code, ThemeData theme) {
    bool isSelected = _currentLanguage == code;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.language_rounded,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(name),
      trailing: isSelected 
        ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
        : null,
      onTap: () => _changeLanguage(code),
    );
  }
}