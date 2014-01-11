library router;

import 'package:angular/angular.dart';

class AppRouteInitializer implements RouteInitializer {
  init(Router router, ViewFactory view) {
    router.root
      ..addRoute(
          name: 'welcome',
          path: '/welcome',
          defaultRoute: true,
          enter: view('views/welcome.html'))
      ..addRoute(
          name: 'camera',
          path: '/camera',
          enter: view('views/camera.html'))
      ..addRoute(
          name: 'activities',
          path: '/activities',
          enter: view('views/activities.html'));
  }
}