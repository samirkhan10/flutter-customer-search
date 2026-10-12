import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../utils/dates.dart';

class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({super.key, required this.customer});

  final Customer customer;

  IconData _addressIcon(String type) => switch (type.toLowerCase()) {
        'home' => Icons.home_outlined,
        'business' => Icons.business_outlined,
        'mailing' => Icons.markunread_mailbox_outlined,
        _ => Icons.place_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final c = customer;

    return Scaffold(
      appBar: AppBar(title: Text(c.fullName)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const _SectionHeader('Basic information'),
            _InfoRow(label: 'First name', value: c.firstName),
            _InfoRow(label: 'Last name', value: c.lastName),
            _InfoRow(label: 'Date of birth', value: prettyDate(c.dateOfBirth)),
            _InfoRow(label: 'Marital status', value: c.maritalStatus),
            _SecureIdRow(secureId: c.secureId),

            const _SectionHeader('Addresses'),
            if (c.addresses.isEmpty) const _EmptyRow('No addresses on file'),
            for (final a in c.addresses)
              ListTile(
                leading: Icon(_addressIcon(a.type)),
                title: Text(a.street),
                subtitle: Text('${a.cityLine}\n${a.type}'),
                isThreeLine: true,
              ),

            const _SectionHeader('Phones'),
            if (c.phones.isEmpty) const _EmptyRow('No phone numbers on file'),
            for (final p in c.phones)
              _ContactTile(
                icon: Icons.phone_outlined,
                value: p.number,
                type: p.type,
                isPrimary: p.isPrimary,
              ),

            const _SectionHeader('Emails'),
            if (c.emails.isEmpty) const _EmptyRow('No email addresses on file'),
            for (final e in c.emails)
              _ContactTile(
                icon: Icons.email_outlined,
                value: e.address,
                type: e.type,
                isPrimary: e.isPrimary,
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.trailing});

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(label, style: Theme.of(context).textTheme.bodySmall),
      subtitle: Text(
        value.isEmpty ? '-' : value,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: trailing,
    );
  }
}

class _SecureIdRow extends StatefulWidget {
  const _SecureIdRow({required this.secureId});
  final String secureId;

  @override
  State<_SecureIdRow> createState() => _SecureIdRowState();
}

class _SecureIdRowState extends State<_SecureIdRow> {
  bool _visible = false;

  String get _masked {
    final id = widget.secureId;
    if (id.length <= 4) return id;
    return '•••-••-${id.substring(id.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return _InfoRow(
      label: 'Secure ID',
      value: _visible ? widget.secureId : _masked,
      trailing: IconButton(
        tooltip: _visible ? 'Hide secure ID' : 'Show secure ID',
        icon: Icon(_visible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
        onPressed: () => setState(() => _visible = !_visible),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.value,
    required this.type,
    required this.isPrimary,
  });

  final IconData icon;
  final String value;
  final String type;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: isPrimary ? scheme.primary : null),
      title: Text(
        value,
        style: TextStyle(fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal),
      ),
      subtitle: Text(type),
      trailing: isPrimary
          ? Chip(
              label: const Text('Primary'),
              visualDensity: VisualDensity.compact,
              side: BorderSide.none,
              backgroundColor: scheme.primaryContainer,
            )
          : null,
    );
  }
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.outline)),
    );
  }
}
