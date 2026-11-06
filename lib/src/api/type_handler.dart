import 'package:shelf/shelf.dart';

import '../../database.dart';
import 'http_helpers.dart';

/// Consultation et gestion des types de bière.
class TypeHandler {
  TypeHandler(this._dbService);

  final DatabaseService _dbService;
  // Consulte les types enregistrés.
  Response getAll(Request request) =>
      jsonResponse(_dbService.getTypes().toList());

  // Crée un type à partir d'un libellé valide.
  Future<Response> create(Request request) async {
    _dbService.addType(libelle: await _readLabel(request));
    return Response(201, body: 'Beer type created successfully.\n');
  }

  // Une modification d'un type inexistant renvoie 404.
  Future<Response> update(Request request) async {
    final id = readId(request);
    final label = await _readLabel(request);
    return _dbService.updateType(id: id, libelle: label)
        ? Response.ok('Beer type updated successfully.\n')
        : Response.notFound('Beer type not found.\n');
  }

  // La suppression échoue si le type est utilisé dans un stock.
  Response delete(Request request) => _dbService.deleteType(id: readId(request))
      ? Response.ok('Beer type deleted successfully.\n')
      : Response.notFound('Beer type not found.\n');

  // Vérifie le libellé fourni pour un type.
  Future<String> _readLabel(Request request) async {
    final data = await readJson(request);
    final label = data['libelle'];
    if (label is! String || label.isEmpty) {
      throw const FormatException('Missing or invalid field: libelle');
    }
    return label;
  }
}
