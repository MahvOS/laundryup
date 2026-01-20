import 'package:flutter/material.dart';
import 'package:LaundryUp/generated/app_localizations.dart';
import '../services/api_service.dart';
  
class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _emailOrPhone = '';
  String _whatsapp = '';
  String _password = '';
  bool _isLogin = true;
  String? _errorMessage;

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _errorMessage = null);
      try {
        final trimmedName = _name.trim();
        final trimmedEmailOrPhone = _emailOrPhone.trim();
        final trimmedPassword = _password.trim();
        if (_isLogin) {
          await ApiService.login(trimmedEmailOrPhone, trimmedPassword);
        } else {
          await ApiService.register(
            trimmedName, 
            trimmedEmailOrPhone, 
            trimmedPassword,
            _whatsapp.trim(),
          );
          // After register, login automatically
          await ApiService.login(trimmedEmailOrPhone, trimmedPassword);
        }
        if (!mounted) return;
        final role = await ApiService.getUserRole();
        final route = role == 'staff' ? '/staff' : '/home';
        Navigator.pushReplacementNamed(context, route);
      } catch (e) {
        if (!mounted) return;
        setState(() => _errorMessage = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_laundry_service_rounded,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _isLogin ? l10n.login : l10n.register,
                  style: theme.textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin 
                    ? l10n.greetLogin
                    : l10n.greetRegister,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                if (!_isLogin) ...[
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: l10n.name,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (value) => value!.isEmpty ? l10n.required : null,
                    onChanged: (value) => _name = value,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: l10n.whatsappNumber,
                      prefixIcon: const Icon(Icons.phone_android_rounded),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? l10n.whatsappRequired : null,
                    onChanged: (value) => _whatsapp = value,
                  ),
                  const SizedBox(height: 20),
                ],
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.emailOrPhone,
                    prefixIcon: const Icon(Icons.alternate_email_rounded),
                  ),
                  validator: (value) => value!.isEmpty ? l10n.required : null,
                  onChanged: (value) => _emailOrPhone = value,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                  ),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? l10n.required : null,
                  onChanged: (value) => _password = value,
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(_isLogin ? l10n.login : l10n.register),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin ? l10n.noAccount : l10n.haveAccount,
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: _toggleMode,
                      child: Text(_isLogin ? l10n.register : l10n.login),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
