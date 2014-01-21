library onlinestatus;

import 'dart:html';
import 'dart:async';

class OnlineStatus {
  bool _isOnline;
  StreamController _onOnline = new StreamController();
  StreamController _onOffline = new StreamController();

  OnlineStatus() {
    _isOnline = window.navigator.onLine;
    window.onOffline.listen((_) => _onOffline.add(true));
    window.onOnline.listen((_) => _onOnline.add(true));
  }

  bool get isOnline => _isOnline;

  Stream get onOnline => _onOnline.stream;
  Stream get onOffline => _onOffline.stream;
}