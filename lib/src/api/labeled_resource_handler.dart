import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';

import 'http_helpers.dart';

/// Gestion commune des types et formats de bière.
class LabeledResourceHandler {
  LabeledResourceHandler({
    required this.name,
    required ResultSet Function() list,
    required void Function({required String libelle}) create,
    required bool Function({required int id, required String libelle}) update,
    required bool Function({required int id}) delete,
  }) : _list = list,
       _create = create,
       _update = update,
       _delete = delete;

  final String name;
  final ResultSet Function() _list;
  final void Function({required String libelle}) _create;
  final bool Function({required int id, required String libelle}) _update;
  final bool Function({required int id}) _delete;

  // Les types et formats partagent la validation et les réponses du CRUD.
  Response getAll(Request request) => jsonResponse(_list().toList());

  Future<Response> create(Request request) async {
    _create(libelle: await readLabel(request));
    return Response(201, body: '$name created successfully.\n');
  }

  Future<Response> update(Request request) async {
    final id = readId(request);
    final label = await readLabel(request);
    return _mutationResponse(_update(id: id, libelle: label), 'updated');
  }

  Response delete(Request request) =>
      _mutationResponse(_delete(id: readId(request)), 'deleted');

  // Une modification ou une suppression sans ligne correspondante renvoie 404.
  Response _mutationResponse(bool found, String action) => found
      ? Response.ok('$name $action successfully.\n')
      : Response.notFound('$name not found.\n');
}
