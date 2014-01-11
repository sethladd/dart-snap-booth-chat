library app;

import 'package:angular/angular.dart';
import 'package:logging/logging.dart';

import 'components/welcome.dart';
import 'components/camera.dart';
import 'components/activities.dart';
import 'components/activity_photo.dart';

import 'services/activity.dart';

import 'router.dart';


class MyAppModule extends Module {
  MyAppModule() {
    type(WelcomeComponent);
    type(CameraComponent);
    type(ActivitiesComponent);
    value(ActivityService, new ActivityService());
    type(ActivityPhotoComponent);
    type(RouteInitializer, implementedBy: AppRouteInitializer);
    factory(NgRoutingUsePushState, (_) => new NgRoutingUsePushState.value(false));
  }
}

void main() {

  Logger.root.level = Level.FINEST;
  Logger.root.onRecord.listen((LogRecord r) { print(r.message); });

  ngBootstrap(module: new MyAppModule());

}
