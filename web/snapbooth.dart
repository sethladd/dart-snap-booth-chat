library app;

import 'dart:html';
import 'dart:async';

import 'package:angular/angular.dart';
import 'package:logging/logging.dart';

import 'package:snapboothchat/log_handlers.dart';
import 'package:snapboothchat/shared_html.dart';
import 'package:snapboothchat/persistable_html.dart' as db;
import 'package:serialization/serialization.dart';

import 'components/welcome.dart';
import 'components/camera.dart';
import 'components/activities.dart';
import 'components/friends_find.dart';
import 'components/configuration.dart';
import 'components/activity_photo.dart';

import 'services/photo_service.dart';
import 'services/online_status.dart';
import 'services/user_service.dart';

import 'router.dart';

class MyAppModule extends Module {
  MyAppModule() {
    type(WelcomeComponent);
    type(CameraComponent);
    type(ActivitiesComponent);
    type(ActivityPhotoComponent);
    type(FriendsFindComponent);
    type(ConfigurationComponent);
    type(PictureService);
    type(UserService);
    type(OnlineStatus);
    value(Serialization, new Serialization());
    value(WebSocket, new WebSocket('ws://localhost:8765/ws'));
    type(RouteInitializer, implementedBy: AppRouteInitializer);
    factory(NgRoutingUsePushState, (_) => new NgRoutingUsePushState.value(false));
  }
}

void main() {

  Logger.root.level = Level.FINEST;
  Logger.root.onRecord.listen(onLogRecord);
  Logger log = new Logger('main');

  runZoned(() {
    db.init('snapboothchat', [User, Picture, Friend]).then((_) {
      ngBootstrap(module: new MyAppModule());
    });
  },
  onError: (e, stackTrace) => log.severe('Error starting app', e));

}
