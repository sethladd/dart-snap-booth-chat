library component.find_friends;

import 'package:angular/angular.dart';
import 'dart:html';

@NgComponent(
    selector: 'friends-find',
    templateUrl: 'components/friends_find.html',
    publishAs: 'ctrl'
)
class FriendsFindComponent implements NgShadowRootAware {

  @override
  void onShadowRoot(ShadowRoot shadowRoot) {
    // TODO: implement onShadowRoot
  }

}