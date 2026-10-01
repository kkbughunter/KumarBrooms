import 'package:flutter/material.dart';

import '../../core/api/api_exception.dart';
import '../../shared/widgets/async_error_card.dart';
import '../auth/auth_service.dart';
import 'widgets/dashboard_header.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key, required this.authService});
  final AuthService authService;

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  List<Map<String, dynamic>> _users = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final users = await widget.authService.loadOrganizationUsers();
      if (mounted) setState(() => _users = users);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _users.where((user) => user['isActive'] == true).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Admin dashboard')),
      body: RefreshIndicator(
        onRefresh: _loadUsers,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DashboardHeader(
                        user: widget.authService.user!, label: 'Administrator'),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _MetricCard(
                            label: 'Total users',
                            value: '${_users.length}',
                            icon: Icons.groups_outlined),
                        _MetricCard(
                            label: 'Active users',
                            value: '$active',
                            icon: Icons.verified_user_outlined),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Organization users',
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
                      AsyncErrorCard(message: _error!, onRetry: _loadUsers)
                    else if (_users.isEmpty)
                      const Card(
                          child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text('No users found.')))
                    else
                      Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            for (var index = 0;
                                index < _users.length;
                                index++) ...[
                              _UserTile(user: _users[index]),
                              if (index != _users.length - 1)
                                const Divider(height: 1),
                            ],
                          ],
                        ),
                      ),
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

class _MetricCard extends StatelessWidget {
  const _MetricCard(
      {required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon,
                  size: 30, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(value,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text(label),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});
  final Map<String, dynamic> user;

  @override
  Widget build(BuildContext context) {
    final roles = (user['roles'] as List<dynamic>? ?? const []).join(', ');
    final active = user['isActive'] == true;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      leading: CircleAvatar(
          child: Text((user['fullName'] as String? ?? 'U')[0].toUpperCase())),
      title: Text(user['fullName'] as String? ?? 'Unnamed user'),
      subtitle:
          Text('${user['email'] ?? ''}${roles.isEmpty ? '' : ' • $roles'}'),
      trailing: Chip(
        avatar:
            Icon(active ? Icons.check_circle : Icons.pause_circle, size: 17),
        label: Text(active ? 'Active' : 'Inactive'),
      ),
    );
  }
}
