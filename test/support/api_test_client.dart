import 'package:dart_apirest/api_handler.dart';
import 'package:dart_apirest/db/database.dart';
import 'package:shelf/shelf.dart';

class ApiTestClient {
  ApiTestClient() : database = DatabaseService(path: ':memory:')..initialize() {
    handler = ApiHandler(database).router;
  }

  final DatabaseService database;
  late final Handler handler;

  Future<Response> send(String method, String path, {String? body}) async {
    return await handler(
      Request(method, Uri.parse('http://localhost$path'), body: body),
    );
  }

  void close() => database.dispose();
}
