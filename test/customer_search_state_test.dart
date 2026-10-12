import 'package:care247_customer_search/data/customer_api.dart';
import 'package:care247_customer_search/data/customer_repository.dart';
import 'package:care247_customer_search/state/customer_search_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fixtures.dart';

CustomerSearchController controllerWith(int status, String body) {
  final client = MockClient((_) async => http.Response(body, status));
  return CustomerSearchController(
    CustomerRepository(CustomerApi(client: client, baseUrl: 'http://test')),
  );
}

List<Type> recordStates(CustomerSearchController controller) {
  final seen = <Type>[];
  controller.addListener(() => seen.add(controller.state.runtimeType));
  return seen;
}

void main() {
  test('starts in the initial state', () {
    expect(controllerWith(200, '[]').state, isA<SearchInitial>());
  });

  test('loading -> success when customers match', () async {
    final controller = controllerWith(200, sampleCustomersJson);
    final seen = recordStates(controller);

    await controller.search({'lastName': 'smith'});

    expect(seen, [SearchLoading, SearchSuccess]);
    expect((controller.state as SearchSuccess).customers.single.id, 'cust-001');
  });

  test('loading -> empty when nothing matches', () async {
    final controller = controllerWith(200, sampleCustomersJson);
    final seen = recordStates(controller);

    await controller.search({'firstName': 'zzz'});

    expect(seen, [SearchLoading, SearchEmpty]);
  });

  test('loading -> error with a readable message on failure', () async {
    final controller = controllerWith(503, '');
    final seen = recordStates(controller);

    await controller.search({});

    expect(seen, [SearchLoading, SearchError]);
    expect((controller.state as SearchError).message, contains('503'));
  });

  test('reset drops a request that is still in flight', () async {
    final controller = controllerWith(200, sampleCustomersJson);

    final pending = controller.search({});
    controller.reset();
    await pending;

    expect(controller.state, isA<SearchInitial>());
  });

  test('does not notify after dispose', () async {
    final controller = controllerWith(200, sampleCustomersJson);
    final pending = controller.search({});
    controller.dispose();

    await expectLater(pending, completes);
  });
}
