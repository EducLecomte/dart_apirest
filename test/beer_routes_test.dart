import 'dart:convert';

import 'package:test/test.dart';

import 'support/api_test_client.dart';

void main() {
  late ApiTestClient api;

  setUp(() => api = ApiTestClient());
  tearDown(() => api.close());

  test('GET /beers retourne les stocks en JSON', () async {
    final response = await api.send('GET', '/beers');

    expect(response.statusCode, 200);
    expect(response.headers['content-type'], contains('application/json'));
    expect(jsonDecode(await response.readAsString()), isA<List<dynamic>>());
  });

  test('POST /beers valide et crée un stock', () async {
    for (final body in [
      '{',
      '[]',
      '{}',
      '{"idType":"1","idFormat":1,"quantite":2}',
    ]) {
      expect((await api.send('POST', '/beers', body: body)).statusCode, 400);
    }

    final missingReference = await api.send(
      'POST',
      '/beers',
      body: '{"idType":99999,"idFormat":1,"quantite":2}',
    );
    expect(missingReference.statusCode, 409);

    final created = await api.send(
      'POST',
      '/beers',
      body: '{"idType":1,"idFormat":1,"quantite":2}',
    );
    expect(created.statusCode, 201);
    expect(await created.readAsString(), 'Beer stock created successfully.\n');

    final response = await api.send('GET', '/beers');
    final stocks = jsonDecode(await response.readAsString()) as List<dynamic>;
    expect(stocks, hasLength(2));
    expect(stocks.last['quantite'], 2);
  });
}
