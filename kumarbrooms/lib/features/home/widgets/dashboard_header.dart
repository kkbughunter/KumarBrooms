import 'package:flutter/material.dart';

import '../../auth/auth_user.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.user, required this.label});

  final AuthUser user;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final initials = user.fullName.trim().isEmpty
        ? 'U'
        : user.fullName
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((part) => part[0].toUpperCase())
            .join();
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: colors.primaryContainer,
          foregroundColor: colors.onPrimaryContainer,
          child: Text(initials,
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome, ${user.fullName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
              const SizedBox(height: 2),
              Text('$label • ${user.orgCode}',
                  style: TextStyle(color: colors.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}
