library component.activity_photo;

import 'package:angular/angular.dart';
import 'dart:html';
import '../models/models.dart';
import '../services/activity.dart';

@NgComponent(
    selector: 'activity-photo',
    templateUrl: 'components/activity_photo.html',
    cssUrl: 'components/activity_photo.css',
    publishAs: 'ctrl'
)
class ActivityPhotoComponent implements NgShadowRootAware {

  ActivityService service;
  Activity activity;
  @NgTwoWay('activity-id') String activityId;

  ActivityPhotoComponent(this.service, RouteProvider routeProvider) {
    activityId = routeProvider.parameters['activityId'];
  }

  @override
  void onShadowRoot(ShadowRoot shadowRoot) {
    activity = service.getById(activityId);
  }

}