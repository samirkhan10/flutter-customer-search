import '../models/customer.dart';
import 'customer_api.dart';

class CustomerRepository {
  CustomerRepository(this._api);

  final CustomerApi _api;

  /// [criteria] maps a field key (from the search config) to what the user typed.
  /// Blank values are ignored, matching is case-insensitive and partial.
  Future<List<Customer>> search(Map<String, String> criteria) async {
    final customers = await _api.getCustomers();
    return filterCustomers(customers, criteria);
  }
}

List<Customer> filterCustomers(List<Customer> customers, Map<String, String> criteria) {
  final active = <String, String>{
    for (final entry in criteria.entries)
      if (entry.value.trim().isNotEmpty) entry.key: entry.value.trim().toLowerCase(),
  };
  if (active.isEmpty) return customers;

  return customers.where((c) {
    final fields = c.searchableFields;
    return active.entries.every(
      (f) => (fields[f.key] ?? '').toLowerCase().contains(f.value),
    );
  }).toList();
}
