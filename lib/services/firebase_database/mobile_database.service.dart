import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  static final instance = DatabaseService._();

  DatabaseService._();

  dynamic getOnlineStatusRef(String uid) =>
      FirebaseDatabase.instance.reference().child('users-online').child(uid);

  String getOnlineStatusRefPath(String uid) => FirebaseDatabase.instance
      .reference()
      .child('users-online')
      .child(uid)
      .path;

  Future<void> onDisconnectRemove(String uid) => FirebaseDatabase.instance
      .reference()
      .child('users-online')
      .child(uid)
      .onDisconnect()
      .remove();

  Future<void> setOnlineStatus(String uid, Map map) => FirebaseDatabase.instance
      .reference()
      .child('users-online')
      .child(uid)
      .set(map);

  Future<void> removeOnlineStatus(String uid) => FirebaseDatabase.instance
      .reference()
      .child('users-online')
      .child(uid)
      .remove();
}
