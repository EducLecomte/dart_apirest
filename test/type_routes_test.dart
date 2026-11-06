import 'dart:convert';

import 'package:test/test.dart';

import 'support/api_test_client.dart';

void main() {
  late ApiTestClient api;

  setUp(() => api = ApiTestClient());
  tearDown(() => api.close());

  test('GET /types retourne les types en JSON', () async {
    final response = await api.send('GET', '/types');

    expect(response.statusCode, 200);
    expect(response.headers['content-type'], contains('application/json'));
    expect(jsonDecode(await response.readAsString()), isA<List<dynamic>>());
  });

  test('POST /types crée un type et valide les données', () async {
    final created = await api.send(
      'POST',
      '/types',
      body: '{"libelle":"Test"}',
    );
    expect(created.statusCode, 201);
    expect(await created.readAsString(), 'Beer type created successfully.\n');

    for (final body in ['{', '[]', '{}', '{"libelle":1}', '{"libelle":""}']) {
      expect((await api.send('POST', '/types', body: body)).statusCode, 400);
    }
  });

  test('PUT /types/<id> modifie un type et valide la requête', () async {
    final created = await api.send(
      'POST',
      '/types',
      body: '{"libelle":"Test"}',
    );
    expect(created.statusCode, 201);

    final types =
        jsonDecode(await (await api.send('GET', '/types')).readAsString())
            as List<dynamic>;
    final id = types.singleWhere((item) => item['libelle'] == 'Test')['id'];
    final updated = await api.send(
      'PUT',
      '/types/$id',
      body: '{"libelle":"Modifié"}',
    );
    expect(updated.statusCode, 200);
    expect(await updated.readAsString(), 'Beer type updated successfully.\n');

    for (final body in ['{', '[]', '{}', '{"libelle":1}', '{"libelle":""}']) {
      expect((await api.send('PUT', '/types/$id', body: body)).statusCode, 400);
    }
    expect(
      (await api.send(
        'PUT',
        '/types/abc',
        body: '{"libelle":"Test"}',
      )).statusCode,
      400,
    );
    final invalidId = await api.send('PUT', '/types/abc', body: '{');
    expect(await invalidId.readAsString(), 'Invalid ID format.');

    final missing = await api.send(
      'PUT',
      '/types/99999',
      body: '{"libelle":"Test"}',
    );
    expect(missing.statusCode, 404);
    expect(await missing.readAsString(), 'Beer type not found.\n');
  });

  test('DELETE /types/<id> supprime un type et gère les erreurs', () async {
    final created = await api.send(
      'POST',
      '/types',
      body: '{"libelle":"À supprimer"}',
    );
    expect(created.statusCode, 201);
    final types =
        jsonDecode(await (await api.send('GET', '/types')).readAsString())
            as List<dynamic>;
    final id = types.singleWhere(
      (item) => item['libelle'] == 'À supprimer',
    )['id'];

    final deleted = await api.send('DELETE', '/types/$id');
    expect(deleted.statusCode, 200);
    expect(await deleted.readAsString(), 'Beer type deleted successfully.\n');

    final missing = await api.send('DELETE', '/types/$id');
    expect(missing.statusCode, 404);
    expect(await missing.readAsString(), 'Beer type not found.\n');

    expect((await api.send('DELETE', '/types/abc')).statusCode, 400);
    final referenced = await api.send('DELETE', '/types/1');
    expect(referenced.statusCode, 409);
  });
}
