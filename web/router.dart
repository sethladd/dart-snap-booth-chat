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
          name: 'view',
          path: '/activities/:activityId',
          enter: view('views/activity.html')
      )
      ..addRoute(
          name: 'friends_find',
          path: '/friends/find',
          enter: view('views/friends_find.html')
      )
      ..addRoute(
          name: 'configuration',
          path: '/configuration',
          enter: view('views/configuration.html'))
      ..addRoute(
          name: 'activities',
          path: '/activities',
          enter: view('views/activities.html'),
          mount: (Route route) => route
            ..addRoute(
                name: 'view',
                path: '/:activityId',
                enter: view('views/activity.html')));

  }
}