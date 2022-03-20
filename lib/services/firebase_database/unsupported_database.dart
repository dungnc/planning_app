class DatabaseService {
  static final instance = DatabaseService._();

  DatabaseService._();

  dynamic getOnlineStatusRef(String uid) {
    throw ("Platform not found");
  }

  String getOnlineStatusRefPath(String uid) => throw ("Platform not found");

  Future<void> onDisconnectRemove(String uid) => throw ("Platform not found");

  Future<void> setOnlineStatus(String uid, Map map) =>
      throw ("Platform not found");

  Future<void> removeOnlineStatus(String uid) => throw ("Platform not found");
}
