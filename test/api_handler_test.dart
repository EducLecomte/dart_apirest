import 'dart:convert';

import 'package:dart_apirest/api_handler.dart';
import 'package:dart_apirest/database.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  late DatabaseService database;
  late Handler handler;

  setUp(() {
    database = DatabaseService(path: ':memory:')..initialize();
    handler = ApiHandler(database).router;
  });

  tearDown(() => database.dispose());

  Future<Response> send(String method, String path, {String? body}) async {
    return handler(
      Request(method, Uri.parse('http://localhost$path'), body: body),
    );
  }

  test('documente les routes et conserve echo et 404', () async {
    final root = await send('GET', '/');
    expect(root.statusCode, 200);
    expect(await root.readAsString(), contains('Documentation API Bières'));
    expect(await (await send('GET', '/echo/hello')).readAsString(), 'hello\n');
    expect((await send('GET', '/absent')).statusCode, 404);
  });

  test('retourne les listes en JSON', () async {
    for (final path in ['/beers', '/types', '/formats']) {
      final response = await send('GET', path);
      expect(response.statusCode, 200);
      expect(response.headers['content-type'], contains('application/json'));
      expect(jsonDecode(await response.readAsString()), isA<List>());
    }
  });

  for (final resource in ['types', 'formats']) {
    test('crée, modifie et supprime un élément de $resource', () async {
      final created = await send(
        'POST',
        '/$resource',
        body: '{"libelle":"Test"}',
      );
      expect(created.statusCode, 201);
      final name = resource == 'types' ? 'Beer type' : 'Beer format';
      expect(await created.readAsString(), '$name created successfully.\n');
      final list =
          jsonDecode(await (await send('GET', '/$resource')).readAsString())
              as List<dynamic>;
      final item = list.singleWhere((item) => item['libelle'] == 'Test');
      final id = item['id'];
      final updated = await send(
        'PUT',
        '/$resource/$id',
        body: '{"libelle":"Modifié"}',
      );
      expect(updated.statusCode, 200);
      expect(await updated.readAsString(), '$name updated successfully.\n');
      final deleted = await send('DELETE', '/$resource/$id');
      expect(deleted.statusCode, 200);
      expect(await deleted.readAsString(), '$name deleted successfully.\n');
      final missing = await send('DELETE', '/$resource/$id');
      expect(missing.statusCode, 404);
      expect(await missing.readAsString(), '$name not found.\n');
      final missingUpdate = await send(
        'PUT',
        '/$resource/$id',
        body: '{"libelle":"Test"}',
      );
      expect(missingUpdate.statusCode, 404);
      expect(await missingUpdate.readAsString(), '$name not found.\n');
    });

    test('valide les demandes pour $resource', () async {
      for (final body in ['{', '[]', '{}', '{"libelle":1}', '{"libelle":""}']) {
        expect((await send('POST', '/$resource', body: body)).statusCode, 400);
        expect((await send('PUT', '/$resource/1', body: body)).statusCode, 400);
      }
      expect(
        (await send(
          'PUT',
          '/$resource/abc',
          body: '{"libelle":"Test"}',
        )).statusCode,
        400,
      );
      expect((await send('DELETE', '/$resource/abc')).statusCode, 400);
      final invalidId = await send('PUT', '/$resource/abc', body: '{');
      expect(await invalidId.readAsString(), 'Invalid ID format.');
    });

    test('refuse la suppression de $resource référencé par un stock', () async {
      expect((await send('DELETE', '/$resource/1')).statusCode, 409);
      expect((await send('GET', '/beers')).statusCode, 200);
    });
  }

  test(
    'les modifications des types et formats restent indépendantes',
    () async {
      expect(
        (await send('POST', '/types', body: '{"libelle":"Commun"}')).statusCode,
        201,
      );
      expect(
        (await send(
          'POST',
          '/formats',
          body: '{"libelle":"Commun"}',
        )).statusCode,
        201,
      );

      final types =
          jsonDecode(await (await send('GET', '/types')).readAsString())
              as List<dynamic>;
      final typeId = types.singleWhere(
        (item) => item['libelle'] == 'Commun',
      )['id'];
      expect(
        (await send(
          'PUT',
          '/types/$typeId',
          body: '{"libelle":"Type modifié"}',
        )).statusCode,
        200,
      );
      final formats =
          jsonDecode(await (await send('GET', '/formats')).readAsString())
              as List<dynamic>;
      expect(
        formats.where((item) => item['libelle'] == 'Commun'),
        hasLength(1),
      );
      expect(
        formats.where((item) => item['libelle'] == 'Type modifié'),
        isEmpty,
      );
    },
  );

  test('valide et crée les stocks', () async {
    for (final body in [
      '{',
      '[]',
      '{}',
      '{"idType":"1","idFormat":1,"quantite":2}',
    ]) {
      expect((await send('POST', '/beers', body: body)).statusCode, 400);
    }
    expect(
      (await send(
        'POST',
        '/beers',
        body: '{"idType":99999,"idFormat":1,"quantite":2}',
      )).statusCode,
      409,
    );
    expect(
      (await send(
        'POST',
        '/beers',
        body: '{"idType":1,"idFormat":1,"quantite":2}',
      )).statusCode,
      201,
    );
    final stocks =
        jsonDecode(await (await send('GET', '/beers')).readAsString())
            as List<dynamic>;
    expect(stocks, hasLength(2));
  });
}
