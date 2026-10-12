import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../state/customer_search_state.dart';
import '../widgets/customer_list_item.dart';
import '../widgets/message_view.dart';
import 'customer_detail_screen.dart';

class CustomerResultsScreen extends StatelessWidget {
  const CustomerResultsScreen({super.key, required this.search});

  final CustomerSearchController search;

  void _openDetails(BuildContext context, Customer customer) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CustomerDetailScreen(customer: customer)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: ListenableBuilder(
        listenable: search,
        builder: (context, _) => switch (search.state) {
          SearchInitial() || SearchLoading() => const Center(
              child: CircularProgressIndicator(semanticsLabel: 'Loading customers'),
            ),
          SearchEmpty() => _Refreshable(
              onRefresh: search.refresh,
              child: const MessageView(
                icon: Icons.person_search_outlined,
                title: 'No customers found',
                message: 'Try fewer or different search details.',
              ),
            ),
          SearchError(:final message) => _Refreshable(
              onRefresh: search.refresh,
              child: MessageView(
                icon: Icons.cloud_off_outlined,
                title: "Couldn't load customers",
                message: message,
                onRetry: search.retry,
              ),
            ),
          SearchSuccess(:final customers) => RefreshIndicator(
              onRefresh: search.refresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: customers.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, i) => CustomerListItem(
                  key: ValueKey(customers[i].id),
                  customer: customers[i],
                  onTap: () => _openDetails(context, customers[i]),
                ),
              ),
            ),
        },
      ),
    );
  }
}

/// Lets pull-to-refresh work on non-list states (empty / error) too.
class _Refreshable extends StatelessWidget {
  const _Refreshable({required this.onRefresh, required this.child});

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        ),
      ),
    );
  }
}
