import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';

void main() {
  late Directory temporaryDirectory;
  late Process server;
  late String host;

  setUpAll(() async {
    final project = Directory.current.path;
    temporaryDirectory = await Directory.systemTemp.createTemp('dart-apirest-');
    server = await Process.start(
      Platform.resolvedExecutable,
      [
        '--packages=$project/.dart_tool/package_config.json',
        '$project/bin/server.dart',
      ],
      workingDirectory: temporaryDirectory.path,
      environment: {'PORT': '0'},
    );
    server.stderr.transform(utf8.decoder).listen(stderr.write);
    final ready = Completer<String>();
    server.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) {
            if (line.startsWith('Server listening on port ') &&
                !ready.isCompleted) {
              ready.complete(line);
            }
          },
          onDone: () {
            if (!ready.isCompleted) {
              ready.completeError(StateError('Server exited before starting.'));
            }
          },
        );
    final listening = await ready.future.timeout(const Duration(seconds: 15));
    host = 'http://127.0.0.1:${listening.split(' ').last}';
  });

  tearDownAll(() async {
    server.kill(ProcessSignal.sigint);
    await server.exitCode;
    await temporaryDirectory.delete(recursive: true);
  });

  test('Root', () async {
    final response = await get(Uri.parse('$host/'));
    expect(response.statusCode, 200);
    expect(response.body, contains('Documentation API Bières'));
  });

  test('Echo', () async {
    final response = await get(Uri.parse('$host/echo/hello'));
    expect(response.statusCode, 200);
    expect(response.body, 'hello\n');
  });

  test('404', () async {
    final response = await get(Uri.parse('$host/foobar'));
    expect(response.statusCode, 404);
  });
}
