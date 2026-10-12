import 'package:care247_customer_search/data/customer_api.dart';
import 'package:care247_customer_search/data/customer_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fixtures.dart';

CustomerRepository repoReturning(http.Response response) {
  final client = MockClient((_) async => response);
  return CustomerRepository(CustomerApi(client: client, baseUrl: 'http://test'));
}

void main() {
  group('search filtering', () {
    final repo = repoReturning(http.Response(sampleCustomersJson, 200));

    test('empty criteria returns everyone', () async {
      final result = await repo.search({'firstName': '', 'lastName': '  '});
      expect(result, hasLength(3));
    });

    test('matches partially and ignores case', () async {
      final result = await repo.search({'firstName': 'jo'});
      expect(result.map((c) => c.id), ['cust-001']);
    });

    test('combines fields with AND', () async {
      final hit = await repo.search({'firstName': 'john', 'dateOfBirth': '1985-03-15'});
      final miss = await repo.search({'firstName': 'john', 'dateOfBirth': '1990-07-22'});

      expect(hit, hasLength(1));
      expect(miss, isEmpty);
    });

    test('works for a field that is not in the default config', () async {
      final result = await repo.search({'maritalStatus': 'single'});
      expect(result.single.firstName, 'Sarah');
    });
  });

  group('errors', () {
    test('non-200 response becomes an ApiException', () {
      final repo = repoReturning(http.Response('oops', 500));
      expect(repo.search({}), throwsA(isA<ApiException>()));
    });

    test('unexpected body becomes an ApiException', () {
      final repo = repoReturning(http.Response('{"not": "a list"}', 200));
      expect(repo.search({}), throwsA(isA<ApiException>()));
    });

    test('network failure becomes an ApiException', () {
      final client = MockClient((_) => throw const SocketLikeError());
      final repo = CustomerRepository(CustomerApi(client: client, baseUrl: 'http://test'));
      expect(repo.search({}), throwsA(isA<ApiException>()));
    });
  });
}

class SocketLikeError implements Exception {
  const SocketLikeError();
}
