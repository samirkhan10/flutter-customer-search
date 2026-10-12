import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/env.dart';
import '../models/customer.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class CustomerApi {
  CustomerApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? Env.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;
  static const _timeout = Duration(seconds: 10);

  Future<List<Customer>> getCustomers() async {
    final http.Response res;
    try {
      res = await _client.get(Uri.parse('$_baseUrl/customers')).timeout(_timeout);
    } on TimeoutException {
      throw const ApiException('The server took too long to respond. Please try again.');
    } catch (_) {
      throw const ApiException(
          "Could not reach the server. You need to Check your connection and make sure the API is running.");
    }

    if (res.statusCode != 200) {
      throw ApiException('The server returned an error (${res.statusCode}). Please try again.');
    }

    try {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Customer.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      throw const ApiException('We received data in an unexpected format.');
    }
  }

  void close() => _client.close();
}
