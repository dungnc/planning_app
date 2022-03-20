import 'dart:async';

import 'package:agileplanning/models/user.model.dart';
import 'package:agileplanning/services/analytics.service.dart';
import 'package:agileplanning/services/firebase_database/database.service.dart';
import 'package:agileplanning/services/logging.service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class UserBloc {
  static final _log = LoggingService.withTag((UserBloc).toString());

  Future<void> goOnline() async {
    _log.fine('[goOnline] Wait for user...');
    final authResult = await FirebaseAuth.instance.signInAnonymously();

    assert(authResult != null);

    _log.fine(
        '[goOnline] ${DatabaseService.instance.getOnlineStatusRefPath(authResult.user.uid)}');
    await DatabaseService.instance.onDisconnectRemove(authResult.user.uid);
    return DatabaseService.instance
        .setOnlineStatus(authResult.user.uid, {'isOnline': true});
  }

  goOffline() async {
    _log.fine('[goOffline] Wait for user...');
    final firebaseUser = await FirebaseAuth.instance
        .authStateChanges()
        .where((firebaseUser) => firebaseUser != null)
        .first;
    _log.fine('[goOffline] ${firebaseUser.uid}');
    DatabaseService.instance.removeOnlineStatus(firebaseUser.uid);
  }

  Stream<bool> get isOnboarded => FirebaseAuth.instance
      .authStateChanges()
      .where((firebaseUser) => firebaseUser != null)
      .switchMap((firebaseUser) => FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots())
      .map((doc) =>
          doc.exists ? PokerUser.fromFirestore(doc).isOnboarded : false);

  Stream<PokerUser> get currentUser => FirebaseAuth.instance
      .authStateChanges()
      .where((firebaseUser) => firebaseUser != null)
      .switchMap((firebaseUser) => FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots())
      .map((doc) => PokerUser.fromFirestore(doc));

  get isSignedIn =>
      FirebaseAuth.instance.authStateChanges().map((u) => u != null);

  signOut() {
    AnalyticsService.logSignOut();
    FirebaseAuth.instance.signOut();
  }

  resetOnboarding() async {
    final PokerUser user = await currentUser.first;
    assert(user != null);
    user.clearOnboarding();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .set(user.toJson());
  }
}
