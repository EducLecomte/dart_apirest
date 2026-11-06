import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sqlite3/sqlite3.dart';

// Traduit les erreurs de validation et de base de données en réponses HTTP.
// Les erreurs internes sont journalisées sans exposer leurs détails au client.
Middleware get handleErrors =>
    (innerHandler) => (request) async {
      try {
        return await innerHandler(request);
      } on FormatException catch (error) {
        return Response(400, body: error.message);
      } on SqliteException catch (error, stackTrace) {
        if (error.extendedResultCode == 787) {
          return Response(409, body: 'Conflicting database reference.');
        }
        stderr.writeln('Database error: $error\n$stackTrace');
        return Response.internalServerError(body: 'Internal server error.');
      } catch (error, stackTrace) {
        stderr.writeln('API error: $error\n$stackTrace');
        return Response.internalServerError(body: 'Internal server error.');
      }
    };

// Les listes sont renvoyées au format JSON.
Response jsonResponse(Object data) => Response.ok(
  jsonEncode(data),
  headers: {'Content-Type': 'application/json'},
);

// Un corps doit être un objet JSON avant toute validation des champs.
Future<Map<String, dynamic>> readJson(Request request) async {
  final Object? data;
  try {
    data = jsonDecode(await request.readAsString());
  } on FormatException {
    throw const FormatException('Invalid JSON body.');
  }
  if (data is! Map<String, dynamic>) {
    throw const FormatException('Expected a JSON object.');
  }
  return data;
}

// Vérifie l'identifiant présent dans l'URL.
int readId(Request request) {
  final id = int.tryParse(request.params['id'] ?? '');
  if (id == null) throw const FormatException('Invalid ID format.');
  return id;
}

// Les types et les formats nécessitent un libellé non vide.
Future<String> readLabel(Request request) async {
  final data = await readJson(request);
  final label = data['libelle'];
  if (label is! String || label.isEmpty) {
    throw const FormatException('Missing or invalid field: libelle');
  }
  return label;
}
