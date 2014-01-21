library server;

import 'package:args/args.dart' show ArgParser, ArgResults;
import 'package:http_server/http_server.dart' show HttpBodyHandler, HttpRequestBody, VirtualDirectory;
import 'dart:io' show ContentType, File, HttpRequest, HttpResponse, HttpServer, Options, Platform, WebSocketTransformer;
import 'package:logging/logging.dart' show Level, LogRecord, Logger;
import 'package:route/server.dart' show Router, UrlPattern;
import 'package:path/path.dart' as path;
import 'dart:convert' show JSON;
import 'dart:async' show Completer, EventSink, Future, Stream, StreamController, StreamTransformer, runZoned;
import 'dart:math' show Random;
import 'package:crypto/crypto.dart' show MD5;
import 'package:snapboothchat/persistable_io.dart' as db;
import 'package:http/http.dart' as http;
import 'package:serialization/serialization.dart' show Serialization;
import 'package:google_oauth2_client/google_oauth2_console.dart' as oauth2;
import 'package:google_plus_v1_api/plus_v1_api_console.dart' show Plus;
import 'package:google_plus_v1_api/plus_v1_api_client.dart' show Person, PeopleFeed;
import 'package:snapboothchat/log_handlers.dart' show onLogRecord;
import 'package:snapboothchat/shared_io.dart' show User;

part 'oauth_handler.dart';

final Logger log = new Logger('Server');
final Serialization serializer = new Serialization();

configureLogger() {
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(onLogRecord);
}

final UrlPattern getMatchUrl = new UrlPattern(r'/matches/(\d+)');
final UrlPattern gameForMatchUrl = new UrlPattern(r'/matches/(\d+)/game/(\d+)');

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

    db.init(dbUrl)
    .then((_) => HttpServer.bind('0.0.0.0', webServerPort))
    .then((HttpServer server) {

      VirtualDirectory staticFiles = new VirtualDirectory(root)
        ..jailRoot = false
        ..followLinks = true;

      new Router(server)
        //..filter(new RegExp(r'^.*$'), addCorsHeaders)          // Required if also using the Editor's server
        ..serve('/session', method: 'GET').listen(oauthSession)
        ..serve('/connect', method: 'POST').listen(oauthConnect) // TODO use HttpBodyHandler when dartbug.com/14259 is fixed
        ..serve('/register', method: 'POST')
          .transform(new HttpBodyHandler()).listen(registerPlayer)
        ..serve('/friendsToChat', method: 'GET').listen(friendsToChat)
        ..serve(r'/admin/matches/update', method: 'POST')
        ..serve(r'/ws/pictures').transform(new WebSocketTransformer()).listen(pictureMessage)

        ..defaultStream.listen(staticFiles.serveRequest);

      log.info('Server running');
    });

  },
  onError: (e, stackTrace) => log.severe("Error handling request: $e", e, stackTrace));

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


void registerPlayer(HttpRequestBody body) {
  log.fine('Register player');
  Map data = body.body;
  String gplusId = data['gplus_id'];

  // TODO check the logged in session user matches this user

  db.Persistable.findOneBy(User, {'gplus_id':gplusId}).then((User p) {
    if (p == null) {
      User player = new User()
        ..gplus_id = data['gplus_id']
        ..name = data['name'];
      return player.store().then((_) => body.request.response.statusCode = 201);
    } else {
      body.request.response.statusCode = 200;
      return true;
    }
  })
  .then((_) {
    log.fine('All done registering');
    body.request.response.close();
  })
  .catchError((e, stackTrace) => _handleError(body.request.response, e, stackTrace));
}

/**
 * Returns a list of friends that have also installed the game.
 */
void friendsToChat(HttpRequest request) {
  log.fine('Inside getFriendPlayers');

  String accessToken = request.session["access_token"];

  bool transformIsDone = false;

  // TODO do this with a StreamTransformer
  _getAllFriends(accessToken).toList()

    // Convert G+ Person to IDs
    .then((List<List<Person>> friends) {
      log.fine('Finding friends: ${friends.length} groups found');
      return friends.map((List<Person> someFriends) {
        return someFriends.map((Person p) => p.id).toList(growable: false);
      });
    })

    // Check the DB if the IDs are also Players
    .then((List<List<String>> allIds) {
      return allIds.map((List<String> ids) {
        log.fine('Finding friends: ${ids.length} friends might be players');
        return db.Persistable.findBy(User, {'gplus_id': ids}).toList();
      });
    })

    // Wait for all queries into DB to finish
    .then((List<Future<List<User>>> queries) {
      return Future.wait(queries);
    })

    // Create a flat list of all players that are also friends
    .then((List<List<User>> allPlayers) {
      return allPlayers.expand((i) => i).toList();
    })

    // Send all friend players to client as JSON
    .then((List<User> friendPlayers) {
      log.fine('Finding friends: ${friendPlayers.length} actual friends are players');
      _sendJson(request.response, friendPlayers);
    })

    .catchError((e, stackTrace) {
      log.warning('Problem finding friends: $e', e, stackTrace);
      request.response.statusCode = 500;
      request.response.close();
    });

}

Stream<List<Person>> _getAllFriends(String accessToken) {
  Plus plusclient = makePlusClient(accessToken);

  StreamController stream = new StreamController();

  Future consumePeople([String nextToken]) {
    return _getPageOfFriends(plusclient, nextPageToken: nextToken)
      .then((PeopleFeed feed) {
        stream.add(feed.items);
        if (feed.nextPageToken != null) {
          return consumePeople(feed.nextPageToken);
        }
      });
  }

  consumePeople()
      .catchError(stream.addError)
      .whenComplete(stream.close);

  return stream.stream;
}

Future<PeopleFeed> _getPageOfFriends(Plus plusclient,
    {String orderBy: 'best', int maxResults: 100, String nextPageToken}) {
  return plusclient.people.list('me', 'visible', orderBy: orderBy,
      maxResults: maxResults, pageToken: nextPageToken);
}

// TODO: this should get better.
// See https://code.google.com/p/dart/issues/detail?id=14416
void _handleError(HttpResponse response, e, StackTrace stackTrace) {
  log.severe('Oh noes! $e', e, stackTrace);
  response.statusCode = 500;
  response.close();
}

Plus makePlusClient(String accessToken) {
  oauth2.SimpleOAuth2Console simpleOAuth2 = new oauth2.SimpleOAuth2Console(CLIENT_ID, CLIENT_SECRET, accessToken);
  Plus plusclient = new Plus(simpleOAuth2);
  plusclient.makeAuthRequests = true;
  return plusclient;
}

_sendJson(HttpResponse response, var payload) {
  String json = JSON.encode(serializer.write(payload));
  response.headers.contentType = ContentType.parse('application/json');
  response.contentLength = json.length;
  response.write(json);
  response.close();
}

_respondWithMessage(HttpResponse resp, int statusCode, String message) {
  resp.statusCode = statusCode;
  resp.write(message);
  resp.close();
}

void pictureMessage(dynamic event) {
  var message = serializer.read(JSON.decode(event));
}
