import 'package:flutter/material.dart';

import '../../core/api/api_exception.dart';
import '../../shared/widgets/async_error_card.dart';
import '../auth/auth_service.dart';
import 'widgets/dashboard_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.authService});
  final AuthService authService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _profile;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await widget.authService.loadProfile();
      if (mounted) setState(() => _profile = profile);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.user!;
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DashboardHeader(user: user, label: 'Team member'),
                    const SizedBox(height: 24),
                    Text('Your account',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    if (_loading)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(36),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      )
                    else if (_error != null)
                      AsyncErrorCard(message: _error!, onRetry: _load)
                    else
                      _ProfileCard(profile: _profile!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});
  final Map<String, dynamic> profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _Detail(
                icon: Icons.person_outline,
                label: 'Full name',
                value: profile['fullName']),
            _Detail(
                icon: Icons.mail_outline,
                label: 'Email',
                value: profile['email']),
            _Detail(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: profile['phone']),
            _Detail(
                icon: Icons.badge_outlined,
                label: 'Role',
                value: (profile['roles'] as List?)?.join(', ')),
          ],
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final Object? value;

  @override
  Widget build(BuildContext context) {
    final shown = value?.toString().trim();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(shown == null || shown.isEmpty ? 'Not provided' : shown),
    );
  }
}
