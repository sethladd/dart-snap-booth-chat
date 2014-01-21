library component.find_friends;

import 'package:angular/angular.dart';
import 'dart:html';
import '../services/user_service.dart';
import 'package:snapboothchat/shared_html.dart';

@NgComponent(
    selector: 'friends-find',
    templateUrl: 'components/friends_find.html',
    publishAs: 'ctrl'
)
class FriendsFindComponent implements NgShadowRootAware {

  UserService userService;
  List<User> friends;

  FriendsFindComponent(this.userService);

  @override
  void onShadowRoot(ShadowRoot shadowRoot) {
    userService.all().then((List<User> users) {
      friends = users;
    });
  }

}