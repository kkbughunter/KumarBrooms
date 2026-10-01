import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/routes.dart';
import '../../core/api/api_exception.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/auth_layout.dart';
import 'auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.authService});
  final AuthService authService;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orgName = TextEditingController();
  final _orgCode = TextEditingController();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    for (final controller in [
      _orgName,
      _orgCode,
      _fullName,
      _email,
      _phone,
      _password,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final user = await widget.authService.register(
        orgName: _orgName.text,
        orgCode: _orgCode.text,
        fullName: _fullName.text,
        email: _email.text,
        phone: _phone.text,
        password: _password.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        user.isAdmin ? AppRoutes.adminDashboard : AppRoutes.userDashboard,
        (_) => false,
      );
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Create your workspace',
      subtitle: 'Your first account becomes the organization administrator.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _orgName,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Organization name',
                prefixIcon: Icon(Icons.business_outlined),
              ),
              validator: (value) =>
                  Validators.required(value, 'Organization name'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _orgCode,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9_-]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Organization code',
                helperText: 'Lowercase letters, numbers, - or _',
                prefixIcon: Icon(Icons.tag),
              ),
              validator: (value) {
                final requiredMessage =
                    Validators.required(value, 'Organization code');
                if (requiredMessage != null) return requiredMessage;
                if (value!.length < 3) return 'Use at least 3 characters';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _fullName,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) => Validators.required(value, 'Full name'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.mail_outline),
              ),
              validator: Validators.email,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Phone (optional)',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (value) => value != null && value.length > 20
                  ? 'Phone must not exceed 20 characters'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _password,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _register(),
              decoration: InputDecoration(
                labelText: 'Password',
                helperText: 'At least 8 characters',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                ),
              ),
              validator: (value) =>
                  Validators.password(value, enforceLength: true),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(_error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _register,
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: _submitting
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create organization'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _submitting
                  ? null
                  : () => Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.login),
              child: const Text('Already have an account? Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
