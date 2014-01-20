part of snapboothchat.shared;

class Picture extends Object with Persistable {
  int sender_id;
  int receiver_id;
  DateTime created_at;
  DateTime expires_at;
  String picture_url;
}