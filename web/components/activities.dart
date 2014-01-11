library component.find_friends;

import 'package:angular/angular.dart';
import 'dart:html';
import '../models/models.dart';

@NgComponent(
    selector: 'activities',
    templateUrl: 'components/activities.html',
    cssUrl: 'components/activities.css',
    publishAs: 'ctrl'
)
class ActivitiesComponent implements NgShadowRootAware {

  @override
  void onShadowRoot(ShadowRoot shadowRoot) {
    // TODO: implement onShadowRoot
  }

  List<Activity> activities = [];

  ActivitiesComponent() {
    activities = _load();
  }

  List<Activity> _load() {
    return [
      new Activity('New pic'),
      new Activity('New friend')
    ];
  }

}