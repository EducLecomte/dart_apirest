import 'dart:convert';

import 'package:test/test.dart';

import 'support/api_test_client.dart';

void main() {
  late ApiTestClient api;

  setUp(() => api = ApiTestClient());
  tearDown(() => api.close());

  test('GET /formats retourne les formats en JSON', () async {
    final response = await api.send('GET', '/formats');

    expect(response.statusCode, 200);
    expect(response.headers['content-type'], contains('application/json'));
    expect(jsonDecode(await response.readAsString()), isA<List<dynamic>>());
  });

  test('POST /formats crée un format et valide les données', () async {
    final created = await api.send(
      'POST',
      '/formats',
      body: '{"libelle":"Test"}',
    );
    expect(created.statusCode, 201);
    expect(await created.readAsString(), 'Beer format created successfully.\n');

    for (final body in ['{', '[]', '{}', '{"libelle":1}', '{"libelle":""}']) {
      expect((await api.send('POST', '/formats', body: body)).statusCode, 400);
    }
  });

  test('PUT /formats/<id> modifie un format et valide la requête', () async {
    final created = await api.send(
      'POST',
      '/formats',
      body: '{"libelle":"Test"}',
    );
    expect(created.statusCode, 201);

    final formats =
        jsonDecode(await (await api.send('GET', '/formats')).readAsString())
            as List<dynamic>;
    final id = formats.singleWhere((item) => item['libelle'] == 'Test')['id'];
    final updated = await api.send(
      'PUT',
      '/formats/$id',
      body: '{"libelle":"Modifié"}',
    );
    expect(updated.statusCode, 200);
    expect(await updated.readAsString(), 'Beer format updated successfully.\n');

    for (final body in ['{', '[]', '{}', '{"libelle":1}', '{"libelle":""}']) {
      expect(
        (await api.send('PUT', '/formats/$id', body: body)).statusCode,
        400,
      );
    }
    expect(
      (await api.send(
        'PUT',
        '/formats/abc',
        body: '{"libelle":"Test"}',
      )).statusCode,
      400,
    );
    final invalidId = await api.send('PUT', '/formats/abc', body: '{');
    expect(await invalidId.readAsString(), 'Invalid ID format.');

    final missing = await api.send(
      'PUT',
      '/formats/99999',
      body: '{"libelle":"Test"}',
    );
    expect(missing.statusCode, 404);
    expect(await missing.readAsString(), 'Beer format not found.\n');
  });

  test('DELETE /formats/<id> supprime un format et gère les erreurs', () async {
    final created = await api.send(
      'POST',
      '/formats',
      body: '{"libelle":"À supprimer"}',
    );
    expect(created.statusCode, 201);
    final formats =
        jsonDecode(await (await api.send('GET', '/formats')).readAsString())
            as List<dynamic>;
    final id = formats.singleWhere(
      (item) => item['libelle'] == 'À supprimer',
    )['id'];

    final deleted = await api.send('DELETE', '/formats/$id');
    expect(deleted.statusCode, 200);
    expect(await deleted.readAsString(), 'Beer format deleted successfully.\n');

    final missing = await api.send('DELETE', '/formats/$id');
    expect(missing.statusCode, 404);
    expect(await missing.readAsString(), 'Beer format not found.\n');

    expect((await api.send('DELETE', '/formats/abc')).statusCode, 400);
    final referenced = await api.send('DELETE', '/formats/1');
    expect(referenced.statusCode, 409);
  });

  test('la modification des formats reste indépendante des types', () async {
    expect(
      (await api.send(
        'POST',
        '/types',
        body: '{"libelle":"Commun"}',
      )).statusCode,
      201,
    );
    expect(
      (await api.send(
        'POST',
        '/formats',
        body: '{"libelle":"Commun"}',
      )).statusCode,
      201,
    );

    final types =
        jsonDecode(await (await api.send('GET', '/types')).readAsString())
            as List<dynamic>;
    final typeId = types.singleWhere(
      (item) => item['libelle'] == 'Commun',
    )['id'];
    expect(
      (await api.send(
        'PUT',
        '/types/$typeId',
        body: '{"libelle":"Type modifié"}',
      )).statusCode,
      200,
    );

    final formats =
        jsonDecode(await (await api.send('GET', '/formats')).readAsString())
            as List<dynamic>;
    expect(formats.where((item) => item['libelle'] == 'Commun'), hasLength(1));
    expect(formats.where((item) => item['libelle'] == 'Type modifié'), isEmpty);
  });
}
