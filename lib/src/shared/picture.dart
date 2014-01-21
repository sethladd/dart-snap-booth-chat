part of snapboothchat.shared;

class Picture extends Object with Persistable {
  int sender_id;
  String senderName;
  int receiver_id;
  String receiverName;
  DateTime created_at;
  DateTime expires_at;
  String picture_url;
}