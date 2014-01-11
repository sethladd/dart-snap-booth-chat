library models;

class Activity {
  String message;
  String id;

  Activity(this.id, this.message);

  String toString() => message;
}

class PhotoActivity extends Activity {
  PhotoActivity(String id, String message) : super(id, message);
}