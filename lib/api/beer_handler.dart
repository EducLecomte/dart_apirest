import 'package:shelf/shelf.dart';

import '../db/database.dart';
import '../http_helpers.dart';

/// Consultation et ajout des stocks de bière.
class BeerHandler {
  BeerHandler(this._dbService);

  final DatabaseService _dbService;

  Response getAll(Request request) =>
      jsonResponse(_dbService.getBeers().toList());

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
