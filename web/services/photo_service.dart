library services.activity;

import 'dart:html';
import 'package:snapboothchat/shared_html.dart';
import 'package:serialization/serialization.dart';
import 'dart:async';
import 'dart:convert' show JSON;

class PictureService {

  WebSocket incomingPicturesSocket;
  Serialization serializer;

  final StreamController _incomingPictures = new StreamController();

  PictureService(this.incomingPicturesSocket, this.serializer) {
    incomingPicturesSocket.onMessage.listen((msg) {
      var newPicture = serializer.read(JSON.decode(msg));
      newPicture.store();
      _incomingPictures.add(newPicture);
    });
  }

  Stream<Picture> all() {
    // TODO pull from DB
  }

  Future<Picture> getById(String id) {
    // TODO pull from DB
  }

  Future sendPicture(String receiver, String photoDataUrl) {
    // TODO send over web socket?
  }

  Stream<Picture> get onPicture => _incomingPictures.stream;
}
