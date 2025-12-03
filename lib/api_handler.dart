import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sqlite3/sqlite3.dart';

import 'database.dart';

/// Une classe qui encapsule la logique de l'API : routage et gestionnaires.
class ApiHandler {
  // Conserve une référence au service de base de données.
  final DatabaseService _dbService;

  // Constructeur qui reçoit le service de base de données.
  ApiHandler(this._dbService);

  // Le routeur qui sera exposé au serveur.
  Router get router {
    final router = Router()
      // Route racine pour un message de bienvenue.
      ..get('/', _rootHandler)
      // Route de test qui renvoie le message fourni.
      ..get('/echo/<message>', _echoHandler)
      // --- Routes pour la gestion des stocks de bière ---
      ..get('/beers', _getBeersHandler)
      ..post('/beers', _postBeersHandler)
      // --- Routes pour la gestion des types de bière (CRUD) ---
      ..get('/types', _getTypesHandler)
      ..post('/types', _postTypeHandler)
      ..put('/types/<id>', _putTypeHandler)
      ..delete('/types/<id>', _deleteTypeHandler)
      // --- Routes pour la gestion des formats de bière (CRUD) ---
      ..get('/formats', _getFormatsHandler)
      ..post('/formats', _postFormatHandler)
      ..put('/formats/<id>', _putFormatHandler)
      ..delete('/formats/<id>', _deleteFormatHandler);

    return router;
  }

  // --- Implémentation des gestionnaires ---

  Response _rootHandler(Request req) {
    return Response.ok('<h1>Hello, World!\n</h1>', headers: {'Content-Type': 'text/html'});
  }

  Response _echoHandler(Request request) {
    final message = request.params['message'] ?? 'default';
    return Response.ok('$message\n');
  }

  Response _getBeersHandler(Request request) {
    final beers = _dbService.getBeers();
    return Response.ok(jsonEncode(beers.toList()), headers: {'Content-Type': 'application/json'});
  }

  Future<Response> _postBeersHandler(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final idType = data['idType'] as int?;
      final idFormat = data['idFormat'] as int?;
      final quantite = data['quantite'] as int?;

      if (idType == null || idFormat == null || quantite == null) {
        return Response(400, body: 'Missing required fields: idType, idFormat, quantite');
      }
      _dbService.addBeerStock(idFormat: idFormat, idType: idType, quantite: quantite);
      return Response(201, body: 'Beer stock created successfully.\n');
    } catch (e) {
      return Response.internalServerError(body: 'An error occurred: $e');
    }
  }

  Response _getTypesHandler(Request request) {
    final types = _dbService.getTypes();
    return Response.ok(jsonEncode(types.toList()), headers: {'Content-Type': 'application/json'});
  }

  Future<Response> _postTypeHandler(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final libelle = data['libelle'] as String?;
      if (libelle == null || libelle.isEmpty) {
        return Response(400, body: 'Missing required field: libelle');
      }
      _dbService.addType(libelle: libelle);
      return Response(201, body: 'Beer type created successfully.\n');
    } catch (e) {
      return Response.internalServerError(body: 'An error occurred: $e');
    }
  }

  Future<Response> _putTypeHandler(Request request) async {
    try {
      final id = int.tryParse(request.params['id'] ?? '');
      if (id == null) return Response(400, body: 'Invalid ID format.');

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final libelle = data['libelle'] as String?;
      if (libelle == null || libelle.isEmpty) {
        return Response(400, body: 'Missing required field: libelle');
      }
      _dbService.updateType(id: id, libelle: libelle);
      return Response.ok('Beer type updated successfully.\n');
    } catch (e) {
      return Response.internalServerError(body: 'An error occurred: $e');
    }
  }

  Response _deleteTypeHandler(Request request) {
    final id = int.tryParse(request.params['id'] ?? '');
    if (id == null) return Response(400, body: 'Invalid ID format.');

    try {
      _dbService.deleteType(id: id);
      return Response.ok('Beer type deleted successfully.\n');
    } on SqliteException catch (e) {
      if (e.extendedResultCode == 787) {
        return Response(409, body: 'Cannot delete type: it is currently in use by a stock item.');
      }
      return Response.internalServerError(body: 'Database error: $e');
    } catch (e) {
      return Response.internalServerError(body: 'An error occurred: $e');
    }
  }

  Response _getFormatsHandler(Request request) {
    final formats = _dbService.getFormats();
    return Response.ok(jsonEncode(formats.toList()), headers: {'Content-Type': 'application/json'});
  }

  Future<Response> _postFormatHandler(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final libelle = data['libelle'] as String?;
      if (libelle == null || libelle.isEmpty) {
        return Response(400, body: 'Missing required field: libelle');
      }
      _dbService.addFormat(libelle: libelle);
      return Response(201, body: 'Beer format created successfully.\n');
    } catch (e) {
      return Response.internalServerError(body: 'An error occurred: $e');
    }
  }

  Future<Response> _putFormatHandler(Request request) async {
    final id = int.tryParse(request.params['id'] ?? '');
    if (id == null) return Response(400, body: 'Invalid ID format.');

    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    _dbService.updateFormat(id: id, libelle: data['libelle']);
    return Response.ok('Beer format updated successfully.\n');
  }

  Response _deleteFormatHandler(Request request) {
    final id = int.tryParse(request.params['id'] ?? '');
    if (id == null) return Response(400, body: 'Invalid ID format.');

    _dbService.deleteFormat(id: id);
    return Response.ok('Beer format deleted successfully.\n');
  }
}
