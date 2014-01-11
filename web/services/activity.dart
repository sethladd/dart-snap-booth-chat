library services.activity;

import '../models/models.dart';

class ActivityService {
  Map<String, Activity> activities = {
    '3f2f23f23f': new Activity('3f2f23f23f', 'New pic'),
    'gmblkfgdfg': new Activity('gmblkfgdfg', 'New friend')
  };

  Iterable<Activity> getActivities() {
    return activities.values;
  }

  Activity getById(String id) {
    return activities[id];
  }

  // TODO expose a stream for new activities that come in live
}
