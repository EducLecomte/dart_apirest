import 'package:shelf/shelf.dart';

import '../database/database_service.dart';
import 'api_helpers.dart';

/// Consultation et ajout des stocks de bière.
class BeerStockHandler {
  BeerStockHandler(this._dbService);

  final DatabaseService _dbService;

  Response getAll(Request request) {
    return jsonResponse(_dbService.getBeers().toList());
  }

  Response getById(Request request) {
    final beer = _dbService.getBeer(readId(request));
    return beer == null
        ? Response.notFound('Beer stock not found.\n')
        : jsonResponse(beer);
  }

  Future<Response> create(Request request) async {
    final data = await readJson(request);
    final idType = data['idType'];
    final idFormat = data['idFormat'];
    final quantite = data['quantite'];
    if (idType is! int || idFormat is! int || quantite is! int) {
      throw const FormatException(
        'Missing or invalid fields: idType, idFormat, quantite',
      );
    }
    _dbService.addBeerStock(
      idFormat: idFormat,
      idType: idType,
      quantite: quantite,
    );
    return Response(201, body: 'Beer stock created successfully.\n');
  }
}
