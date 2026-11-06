import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'database.dart';
import 'documentation_page.dart';
import 'src/api/beer_handler.dart';
import 'src/api/http_helpers.dart';
import 'src/api/labeled_resource_handler.dart';

/// Regroupe les routes et les gestionnaires de l'API.
class ApiHandler {
  // Le service de base de données est fourni au gestionnaire de l'API.
  ApiHandler(this._dbService);

  final DatabaseService _dbService;

  // Expose les routes avec un middleware commun de gestion des erreurs.
  Handler get router {
    final beers = BeerHandler(_dbService);
    final types = LabeledResourceHandler(
      name: 'Beer type',
      list: _dbService.getTypes,
      create: _dbService.addType,
      update: _dbService.updateType,
      delete: _dbService.deleteType,
    );
    final formats = LabeledResourceHandler(
      name: 'Beer format',
      list: _dbService.getFormats,
      create: _dbService.addFormat,
      update: _dbService.updateFormat,
      delete: _dbService.deleteFormat,
    );
    final routes = Router()
      // Documentation de l'API et route de test.
      ..get('/', _rootHandler)
      ..get('/echo/<message>', _echoHandler)
      // Gestion des stocks de bière.
      ..get('/beers', beers.getAll)
      ..post('/beers', beers.create)
      // Gestion des types de bière.
      ..get('/types', types.getAll)
      ..post('/types', types.create)
      ..put('/types/<id>', types.update)
      ..delete('/types/<id>', types.delete)
      // Gestion des formats de bière.
      ..get('/formats', formats.getAll)
      ..post('/formats', formats.create)
      ..put('/formats/<id>', formats.update)
      ..delete('/formats/<id>', formats.delete);
    return const Pipeline().addMiddleware(handleErrors).addHandler(routes.call);
  }

  // Sert la documentation et conserve la route de test echo.
  Response _rootHandler(Request request) => Response.ok(
    DocumentationPage.htmlContent,
    headers: {'Content-Type': 'text/html; charset=utf-8'},
  );

  Response _echoHandler(Request request) =>
      Response.ok('${request.params['message'] ?? 'default'}\n');
}
