import 'package:flutter/material.dart';

import '../config/search_config.dart';
import '../data/customer_repository.dart';
import '../state/customer_search_state.dart';
import '../widgets/dynamic_search_form.dart';
import 'customer_results_screen.dart';

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key, required this.repository});

  final CustomerRepository repository;

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  late final CustomerSearchController _search = CustomerSearchController(widget.repository);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _onSearch(Map<String, String> criteria) {
    // ignore a second tap while the results page is already sliding in
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;

    _search.search(criteria);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CustomerResultsScreen(search: _search)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Search')),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Fill in any of the fields below. Leave them all empty to list every customer.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    DynamicSearchForm(
                      fields: searchConfig,
                      onSearch: _onSearch,
                      onClear: _search.reset,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
