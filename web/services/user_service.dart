library services.friends;

import 'dart:async';
import 'package:snapboothchat/shared_html.dart';
import 'package:snapboothchat/persistable_html.dart';
import 'package:angular/angular.dart';
import 'dart:convert' show JSON;
import 'package:serialization/serialization.dart';
import 'online_status.dart';
import 'dart:html';
import 'package:snapboothchat/src/shared/messages.dart';
import 'package:logging/logging.dart';

final Logger log = new Logger('UserService');

class UserService {

  Http http;
  Serialization serializer;
  OnlineStatus onlineStatus;
  WebSocket webSocket;

  UserService(this.http, this.serializer, this.onlineStatus, this.webSocket) {
    currentUser().then((user) {
      if (user.name != null) {
        sendLogin(user.name);
      }
    });
  }

  Future<List<User>> all() {
    if (onlineStatus.isOnline) {
      return http.get('/users/online').then((HttpResponse response) {
          return JSON.decode(serializer.read(response.data));
        });
    } else {
      return new Future.value([]);
    }
  }

  Future<User> currentUser() {
    return Persistable.load('localuser', User).then((user) {
      return (user == null) ? (new User()..id='localuser') : user;
    });
  }

  void sendLogin(String username) {
    log.fine('Sending login with name $username');
    webSocket.send(JSON.encode(serializer.write(new LoginMessage()..name=username)));
  }
}