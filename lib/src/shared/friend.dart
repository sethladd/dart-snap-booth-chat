part of snapboothchat.shared;

class Friend extends Object with Persistable {
  String user1_id;
  String user2_id;

  String toString() => 'User1: $user1_id, User2: $user2_id';
}