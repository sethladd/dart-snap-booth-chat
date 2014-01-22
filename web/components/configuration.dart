library component.configuration;

import 'package:angular/angular.dart';
import 'package:snapboothchat/shared_html.dart';
import 'package:snapboothchat/persistable_html.dart';
import '../services/user_service.dart';
import 'package:logging/logging.dart';
import 'dart:html';
import 'package:serialization/serialization.dart';

final Logger log = new Logger('ConfigurationComponent');

@NgComponent(
    selector: 'configuration',
    templateUrl: 'components/configuration.html',
    //cssUrl: 'components/welcome.css',
    publishAs: 'ctrl'
)
class ConfigurationComponent {
  User user;
  UserService userService;
  WebSocket webSocket;
  Serialization serializer;

  ConfigurationComponent(this.userService, this.webSocket, this.serializer) {
    userService.currentUser().then((u) => user = u);
  }

  void save() {
    user.store()
      .then((_) => log.fine('Saved ${user.name} as username'))
      .then((_) => userService.sendLogin(user.name));
  }

}