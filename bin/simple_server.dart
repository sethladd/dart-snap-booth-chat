library server.simple;

import 'package:logging/logging.dart';
import 'package:serialization/serialization.dart';
import 'package:snapboothchat/log_handlers.dart' show onLogRecord;
import 'package:snapboothchat/src/shared/messages.dart';
import 'package:snapboothchat/shared_io.dart';
import 'package:path/path.dart' as path;
import 'package:args/args.dart';
import 'dart:io';
import 'dart:async';
import 'package:http_server/http_server.dart';
import 'package:route/server.dart';
import 'dart:convert';

final Logger log = new Logger('Server');
final Serialization serializer = new Serialization();

configureLogger() {
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(onLogRecord);
}

main(List<String> arguments) {
  configureLogger();
  ArgParser argsParser = initArgsParser();

  String dbUrl = getDbUrl();
  log.info("DB URL is $dbUrl");

  int webServerPort = getWebServerPort();
  log.info("HTTP port is $webServerPort");

  String root;

  try {
    ArgResults args = argsParser.parse(arguments);
    if (args['help']) {
      print(argsParser.getUsage());
      return;
    }
    root = args['root'];
  } on FormatException catch (e) {
    log.severe(e.message);
    log.severe('Use "--help" to see available options.');
    return;
  }

  log.info('Root directory is $root');

  runZoned(() {

    HttpServer.bind('0.0.0.0', webServerPort)
    .then((HttpServer server) {

      VirtualDirectory staticFiles = new VirtualDirectory(root)
        ..jailRoot = false
        ..followLinks = true;

      new Router(server)
        ..serve(r'/users/online', method: 'GET').listen(getOnlineUsers)
        ..serve(r'/ws/pictures').transform(new WebSocketTransformer()).listen(pictureSocket)
        ..defaultStream.listen(staticFiles.serveRequest);

      log.info('Server running');
    });

  },
  onError: (e, stackTrace) => log.severe("Error handling request: $e", e, stackTrace));
}

Map<String, WebSocket> _socketConnections = {};

void pictureSocket(WebSocket socket) {
  String userName;
  socket.listen((msgData) {
    log.fine('Received msg over socket /ws/pictures: $msgData');
    var message = serializer.read(JSON.encode(msgData));
    if (message is LoginMessage) {
      _socketConnections[(message as LoginMessage).name] = socket;
    } else if (message is Picture) {
      var picMessage = (message as Picture);
      var receiverSocket = _socketConnections[picMessage.receiverName];
      if (receiverSocket != null) {
        receiverSocket.add(msgData);
      } else {
        // TODO: store into DB!
      }
    }
  },
  onDone: () => _socketConnections.remove(userName),
  onError: () => _socketConnections.remove(userName));
}

void getOnlineUsers(HttpRequest req) {
  _sendJson(req.response, _socketConnections.keys);
}

ArgParser initArgsParser() {
  ArgParser argsParser = new ArgParser()
    ..addOption('root',
        defaultsTo: path.join(path.dirname(Platform.script.toString()), '..', 'web'),
        help: 'root directory for the HTTP server')
    ..addFlag('help', help: 'Prints the help information', negatable: false);
  return argsParser;
}

int getWebServerPort() {
  String port = Platform.environment['PORT'];
  if (port == null) {
    return 8765;
  } else {
    return int.parse(port);
  }
}

String getDbUrl() {
  String dbUrl;
  if (Platform.environment['DATABASE_URL'] != null) {
    dbUrl = Platform.environment['DATABASE_URL'];
  } else {
    String user = Platform.environment['USER'];
    dbUrl = 'postgres://$user:@localhost:5432/$user';
  }
  return dbUrl;
}

Future<bool> addCorsHeaders(HttpRequest req) {
  log.fine('Adding CORS headers for ${req.method} ${req.uri}');
  req.response.headers
      ..add('Access-Control-Allow-Origin', 'http://127.0.0.1:3030')
      ..add('Access-Control-Allow-Headers', 'Content-Type')
      ..add('Access-Control-Expose-Headers', 'Location')
      ..add('Access-Control-Allow-Credentials', 'true');
  if (req.method == 'OPTIONS') {
    req.response
        ..statusCode = 200
        ..close(); // TODO: wait for this?
    return new Future.sync(() => false);
  } else {
    return new Future.sync(() => true);
  }
}

_sendJson(HttpResponse response, var payload) {
  String json = JSON.encode(serializer.write(payload));
  response
    ..headers.contentType = ContentType.parse('application/json')
    ..contentLength = json.length
    ..write(json)
    ..close();
}