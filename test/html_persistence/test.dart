library test.html.persistence;

import 'package:snapboothchat/persistable_html.dart' as db;
import 'package:snapboothchat/shared_html.dart';

main() {

  db.init('testapp', [User, Friend])
    .then((_) {
      print('DBs are initialized');
      var user = new User()
        ..gplus_id = 'id'
        ..name = 'name';
      print('storing first user');
      return user.store();
    })
    .then((_) {
      var user2 = new User()
        ..gplus_id = 'id2'
        ..name = 'name2';
      print('storing second user');
      return user2.store();
    })
    .then((_) => db.Persistable.all(User).toList())
    .then((List<User> users) {
      print('all users: $users');
      var friend = new Friend()
        ..user1_id = users.first.id
        ..user2_id = users.last.id;
      return friend.store();
    })
    .then((_) => db.Persistable.all(Friend).toList())
    .then((List<Friend> friends) {
      print('all friends: $friends');
    })
    .catchError((e, stackTrace) => print('$e $stackTrace'));

}