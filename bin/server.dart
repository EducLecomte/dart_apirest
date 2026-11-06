import 'dart:io';

import 'package:dart_apirest/api_handler.dart';
import 'package:dart_apirest/database.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

Future<void> main() async {
  // Initialise la base de données avant de démarrer l'API.
  final dbService = DatabaseService();
  dbService.initialize();

  // Associe le routeur de l'API à la journalisation des requêtes.
  final apiHandler = ApiHandler(dbService);
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(apiHandler.router);

  // Utilise le port de l'environnement ou 8080 par défaut.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  // Écoute sur toutes les interfaces réseau, notamment pour Docker.
  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('Server listening on port ${server.port}');

  // Ferme le serveur et la base de données lors d'un arrêt avec Ctrl+C.
  ProcessSignal.sigint.watch().listen((_) async {
    print('\nShutting down server...');
    await server.close(force: true);
    dbService.dispose();
    exit(0);
  });
}
