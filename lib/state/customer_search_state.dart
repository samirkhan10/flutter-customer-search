import 'package:flutter/foundation.dart';

import '../data/customer_api.dart';
import '../data/customer_repository.dart';
import '../models/customer.dart';

sealed class SearchState {
  const SearchState();
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchSuccess extends SearchState {
  final List<Customer> customers;
  const SearchSuccess(this.customers);
}

class SearchEmpty extends SearchState {
  const SearchEmpty();
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);
}

class CustomerSearchController extends ChangeNotifier {
  CustomerSearchController(this._repo);

  final CustomerRepository _repo;

  SearchState _state = const SearchInitial();
  SearchState get state => _state;

  Map<String, String> _criteria = const {};
  bool _busy = false;
  int _generation = 0;
  bool _disposed = false;

  bool get isBusy => _busy;

  /// A new search always wins: any request still in flight is ignored when it lands.
  Future<void> search(Map<String, String> criteria) async {
    _generation++;
    _criteria = Map.unmodifiable(criteria);
    _emit(const SearchLoading());
    await _load();
  }

  /// Used by pull-to-refresh: keeps the current list on screen while reloading.
  Future<void> refresh() async {
    if (_busy) return;
    await _load();
  }

  Future<void> retry() => search(_criteria);

  void reset() {
    _generation++;
    _busy = false;
    _criteria = const {};
    _emit(const SearchInitial());
  }

  Future<void> _load() async {
    final gen = _generation;
    _busy = true;
    try {
      final result = await _repo.search(_criteria);
      if (gen != _generation) return;
      _emit(result.isEmpty ? const SearchEmpty() : SearchSuccess(result));
    } on ApiException catch (e) {
      if (gen == _generation) _emit(SearchError(e.message));
    } catch (_) {
      if (gen == _generation) _emit(const SearchError('Something went wrong. Please try again.'));
    } finally {
      if (gen == _generation) _busy = false;
    }
  }

  void _emit(SearchState next) {
    // the screen may already be gone by the time a request finishes
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
