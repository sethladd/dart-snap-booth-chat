library component.configuration;

import 'package:angular/angular.dart';
import 'package:snapboothchat/shared_html.dart';
import 'package:snapboothchat/persistable_html.dart';
import '../services/user_service.dart';
import 'package:logging/logging.dart';

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

  String username;

  ConfigurationComponent(this.userService) {
    userService.currentUser().then((u) => user = u);
  }

  void save() {
    if (user == null) {
      user = new User();
    }

    user.name = username;
    user.store()
      .then((_) => log.fine('Saved $username as username'));
  }

}