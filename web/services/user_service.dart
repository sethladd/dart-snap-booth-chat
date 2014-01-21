library services.friends;

import 'dart:async';
import 'package:snapboothchat/shared_html.dart';
import 'package:snapboothchat/persistable_html.dart';
import 'package:angular/angular.dart';
import 'dart:convert' show JSON;
import 'package:serialization/serialization.dart';
import 'online_status.dart';

class UserService {

  Http http;
  Serialization serializer;
  OnlineStatus onlineStatus;

  UserService(this.http, this.serializer, this.onlineStatus);

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
    return Persistable.load('localuser', User);
  }
}