library component.activities;

import 'package:snapboothchat/shared_html.dart';
import 'package:angular/angular.dart';
import 'dart:html';
import '../services/photo_service.dart';

@NgComponent(
    selector: 'activities',
    templateUrl: 'components/activities.html',
    cssUrl: 'components/activities.css',
    publishAs: 'ctrl'
)
class ActivitiesComponent implements NgShadowRootAware {

  Iterable<Picture> activities;

  PictureService service;

  ActivitiesComponent(this.service) {
    service.all().toList().then((pictures) {
      activities = pictures;
    });
  }

  @override
  void onShadowRoot(ShadowRoot shadowRoot) {
    // TODO: implement onShadowRoot
  }

}