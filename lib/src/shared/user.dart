part of snapboothchat.shared;

class User extends Object with Persistable {
  String gplus_id; // TODO enhance persistable my mapping _ to camelcase
  String name;
  String toString() => 'id: [$id], gplus_id: [$gplus_id], name: [$name]';
}