import 'package:test/test.dart';

import 'support/api_test_client.dart';

void main() {
  late ApiTestClient api;

  setUp(() => api = ApiTestClient());
  tearDown(() => api.close());

  test('sert la documentation sur la route racine', () async {
    final response = await api.send('GET', '/');

    expect(response.statusCode, 200);
    expect(response.headers['content-type'], 'text/html; charset=utf-8');
    expect(await response.readAsString(), contains('Documentation API Bières'));
  });

  test('répond à la route echo', () async {
    final response = await api.send('GET', '/echo/hello');

    expect(response.statusCode, 200);
    expect(await response.readAsString(), 'hello\n');
  });

  test('retourne 404 pour une route inconnue', () async {
    final response = await api.send('GET', '/absent');

    expect(response.statusCode, 404);
  });
}
