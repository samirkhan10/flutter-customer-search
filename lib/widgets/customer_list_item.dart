import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../utils/dates.dart';

class CustomerListItem extends StatelessWidget {
  const CustomerListItem({super.key, required this.customer, required this.onTap});

  final Customer customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(child: Text(customer.initials)),
      title: Text(
        customer.fullName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Born ${prettyDate(customer.dateOfBirth)}', style: muted),
          Text(customer.primaryPhone?.number ?? 'No phone', style: muted),
          Text(
            customer.primaryEmail?.address ?? 'No email',
            style: muted,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
