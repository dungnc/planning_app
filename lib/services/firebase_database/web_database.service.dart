import 'package:firebase/firebase.dart' as fb;

class DatabaseService {
  static final instance = DatabaseService._();

  DatabaseService._();

  dynamic getOnlineStatusRef(String uid) =>
      fb.database().ref('users-online/$uid');

  String getOnlineStatusRefPath(String uid) {
    final statusPath = fb.database().ref('users-online/$uid');
    return statusPath.toString().replaceAll(statusPath.root.toString(), '');
  }

  Future<void> onDisconnectRemove(String uid) =>
      fb.database().ref('users-online/$uid').onDisconnect().remove();

  Future<void> setOnlineStatus(String uid, Map map) =>
      fb.database().ref('users-online/$uid').set(map);

  Future<void> removeOnlineStatus(String uid) =>
      fb.database().ref('users-online/$uid').remove();
}
