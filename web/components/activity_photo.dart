library component.activity_photo;

import 'package:angular/angular.dart';
import 'dart:html';
import 'package:snapboothchat/shared_html.dart';
import '../services/photo_service.dart';

@NgComponent(
    selector: 'activity-photo',
    templateUrl: 'components/activity_photo.html',
    cssUrl: 'components/activity_photo.css',
    publishAs: 'ctrl'
)
class ActivityPhotoComponent implements NgShadowRootAware {

  PictureService service;
  Picture picture;
  @NgTwoWay('activity-id') String activityId;

  ActivityPhotoComponent(this.service, RouteProvider routeProvider) {
    activityId = routeProvider.parameters['activityId'];
  }

  @override
  void onShadowRoot(ShadowRoot shadowRoot) {
    service.getById(activityId).then((Picture pic) {
      picture = pic;
    });
  }

}