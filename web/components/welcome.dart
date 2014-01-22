library component.welcome;

import 'package:angular/angular.dart';

import '../services/user_service.dart';

@NgComponent(
    selector: 'welcome',
    templateUrl: 'components/welcome.html',
    //cssUrl: 'components/welcome.css',
    publishAs: 'ctrl'
)
class WelcomeComponent {

  bool hasLocalUser;
  UserService userService;

  WelcomeComponent(this.userService) {
    userService.currentUser().then((user) {
      hasLocalUser = user.name != null;
    });
  }

}