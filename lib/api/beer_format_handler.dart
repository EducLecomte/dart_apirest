import 'package:shelf/shelf.dart';

import '../database/database_service.dart';
import 'api_helpers.dart';

/// Consultation et gestion des formats de bière.
class BeerFormatHandler {
  BeerFormatHandler(this._dbService);

  final DatabaseService _dbService;
  // Consulte les formats enregistrés.
  Response getAll(Request request) =>
      jsonResponse(_dbService.getFormats().toList());

  // Crée un format à partir d'un libellé valide.
  Future<Response> create(Request request) async {
    _dbService.addFormat(libelle: await _readLabel(request));
    return Response(201, body: 'Beer format created successfully.\n');
  }

  // Une modification d'un format inexistant renvoie 404.
  Future<Response> update(Request request) async {
    final id = readId(request);
    final label = await _readLabel(request);
    return _dbService.updateFormat(id: id, libelle: label)
        ? Response.ok('Beer format updated successfully.\n')
        : Response.notFound('Beer format not found.\n');
  }

  // La suppression échoue si le format est utilisé dans un stock.
  Response delete(Request request) =>
      _dbService.deleteFormat(id: readId(request))
      ? Response.ok('Beer format deleted successfully.\n')
      : Response.notFound('Beer format not found.\n');

  // Vérifie le libellé fourni pour un format.
  Future<String> _readLabel(Request request) async {
    final data = await readJson(request);
    final label = data['libelle'];
    if (label is! String || label.isEmpty) {
      throw const FormatException('Missing or invalid field: libelle');
    }
    return label;
  }
}
