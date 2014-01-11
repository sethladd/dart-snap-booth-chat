library component.find_friends;

import 'package:angular/angular.dart';
import 'dart:html';

@NgComponent(
    selector: 'find-friends',
    templateUrl: 'components/find_friends.html',
    cssUrl: 'components/find_friends.css',
    publishAs: 'ctrl'
)
class FindFriendsComponent implements NgShadowRootAware {

  @override
  void onShadowRoot(ShadowRoot shadowRoot) {
    // TODO: implement onShadowRoot
  }

}