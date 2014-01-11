library component.find_friends;

import 'package:angular/angular.dart';
import 'dart:html';
import '../models/models.dart';
import '../services/activity.dart';

@NgComponent(
    selector: 'activities',
    templateUrl: 'components/activities.html',
    cssUrl: 'components/activities.css',
    publishAs: 'ctrl'
)
class ActivitiesComponent implements NgShadowRootAware {

  Iterable<Activity> activities;

  ActivityService service;

  ActivitiesComponent(this.service) {
    activities = service.getActivities();
  }

  @override
  void onShadowRoot(ShadowRoot shadowRoot) {
    // TODO: implement onShadowRoot
  }

}