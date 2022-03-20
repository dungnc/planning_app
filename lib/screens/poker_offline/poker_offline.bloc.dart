import 'dart:async';

import 'package:agileplanning/definitions/poker.constants.dart';
import 'package:agileplanning/models/user.model.dart';
import 'package:agileplanning/services/logging.service.dart';
import 'package:agileplanning/services/performance.service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class PokerOfflineBloc {
  final _logger = LoggingService.withTag((PokerOfflineBloc).toString());
  final _pokerOptions = BehaviorSubject.seeded(pokerOptsDefault.toList());
  final _subscriptions = List<StreamSubscription>();

  Stream<User> get _firebaseUser => FirebaseAuth.instance
      .authStateChanges()
      .where((firebaseUser) => firebaseUser != null);

  PokerOfflineBloc() {
    _subscriptions.add(_firebaseUser
        .switchMap((firebaseUser) => FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .snapshots())
        .map((doc) => PokerUser.fromFirestore(doc))
        .map((user) => user.pokerOptions)
        .listen(_pokerOptions.add));
  }

  String selectedOption;

  Stream<List<String>> get pokerOptions =>
      _pokerOptions.map((event) => event ?? pokerOptsDefault);

  bool get hasSelectedAvatar => selectedOption?.isNotEmpty == true;

  bool isSelected(String option) => selectedOption == option;

  void dispose() {
    _logger.finer('[dispose]');
    _pokerOptions.close();
    _subscriptions.forEach((subscription) => subscription?.cancel());
  }

  /// Remove the user from any potential room in which the user is still
  /// potentially online. This could happen in case of sudden app close or if
  /// the user managed to exit from the room in a unpredicted way (back buttons)
  /// or other exits.
  Future<void> goOfflineInRooms() async {
    _logger.fine('[goOfflineInRooms]');
    PerformanceService.instance.startTrace('offline_all_rooms');

    final firebaseUser = FirebaseAuth.instance.currentUser;
    assert(firebaseUser != null);

    final uid = firebaseUser.uid;
    final snap = await FirebaseFirestore.instance
        .collectionGroup('participants')
        .where('id', isEqualTo: uid)
        .get();

    _logger.fine(
        '[goOfflineInRooms] removing $uid from ${snap.docs.length} rooms');
    final batch = FirebaseFirestore.instance.batch();
    for (var doc in snap.docs) {
      final roomId = doc.reference.parent.parent.id;
      _logger.fine('[goOfflineInRooms] removing $uid from $roomId');
      batch.delete(doc.reference);
    }

    await batch.commit();

    return PerformanceService.instance.stopTrace;
  }

  String getRoomIdFromDeepLink(String deepLink) {
    if (deepLink.contains("roomId=")) {
      return deepLink.split("roomId=")[1];
    }
    return deepLink.split("roomId%3D")[1];
  }
}
