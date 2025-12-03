// Importations des bibliothèques standards de Dart pour la gestion des I/O (serveur) et la conversion JSON.
import 'dart:io';

// Importations des packages pour la création du serveur (shelf) et le routage (shelf_router).
import 'package:dart_apirest/api_handler.dart';
import 'package:dart_apirest/database.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

// Point d'entrée principal de l'application.
void main(List<String> args) async {
  // 1. Initialiser les services
  final dbService = DatabaseService();
  dbService.initialize();

  // 2. Créer le gestionnaire d'API et lui fournir les services nécessaires
  final apiHandler = ApiHandler(dbService);

  // 3. Configurer le pipeline du serveur
  // Initialise la base de données au démarrage du serveur.
  // Écoute sur toutes les interfaces réseau (0.0.0.0), utile pour Docker.
  final ip = InternetAddress.anyIPv4;

  // Crée un "pipeline" de traitement. `logRequests()` est un middleware qui affiche les requêtes entrantes.
  // Le gestionnaire principal est maintenant le routeur de notre `apiHandler`.
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(apiHandler.router);

  // Utilise le port défini par la variable d'environnement PORT, ou 8080 par défaut.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  // 4. Démarrer le serveur
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');

  // Gère l'arrêt propre du serveur (ex: avec Ctrl+C).
  // Cela garantit que la connexion à la base de données est fermée correctement.
  ProcessSignal.sigint.watch().listen((_) async {
    print('\nShutting down server...');
    await server.close(force: true);
    dbService.dispose();
    exit(0);
  });
}
