import 'dart:async';

import 'package:agileplanning/models/room.model.dart';
import 'package:agileplanning/models/room_participant.model.dart';
import 'package:agileplanning/models/user.model.dart';
import 'package:agileplanning/screens/onboarding/onboarding.screen.dart';
import 'package:agileplanning/services/analytics.service.dart';
import 'package:agileplanning/services/firebase_database/web_database.service.dart'
    if (dart.library.io) 'package:agileplanning/services/firebase_database/mobile_database.service.dart'
    if (dart.library.js) 'package:agileplanning/services/firebase_database/web_database.service.dart';
// import 'package:agileplanning/services/firebase_database/web_database.service.dart';
import 'package:agileplanning/services/logging.service.dart';
import 'package:agileplanning/services/performance.service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vibration/vibration.dart';

class PokerOnlineBloc {
  final _logger = LoggingService.withTag((PokerOnlineBloc).toString());
  final isVotingOpenStreamController = StreamController<bool>();
  final String _roomId;
  String _selectedPokerOption;

  set selectedPokerOption(String option) {
    AnalyticsService.logConsiderPokerOption(option);
    _selectedPokerOption = option;
  }

  String get selectedPokerOption => _selectedPokerOption;

  bool get hasSelection => selectedPokerOption?.isNotEmpty == true;

  DocumentReference get _roomRef =>
      FirebaseFirestore.instance.collection('rooms').doc(_roomId);

  PokerOnlineBloc(this._roomId);

  /// When submitting a vote, the voting is only considered to be open and
  /// accepting votes if a round is open and votes are still hidden. As soon
  /// as all participants can see votes, nobody is allowed to submit anymore.
  Stream<Room> get room => _roomRef.snapshots().map((snap) {
        final room = Room.fromFirestore(snap);

        isVotingOpenStreamController.sink
            .add(room?.isVotingOpen == true && room?.hideVotes == true);

        return room;
      }).distinct((previousRoom, nextRoom) {
        if (nextRoom.isVotingOpen && nextRoom.hideVotes) {
          Vibration.vibrate();
        }
        return;
      });

  Stream<String> get roomId => room.map((room) => room?.formattedId);

  Stream<bool> get roomOpenState =>
      room.map((room) => room?.isRoomOpen == true).distinct();

  Stream<bool> get isOnlineInRoom => FirebaseAuth.instance
      .authStateChanges()
      .where((firebaseUser) => firebaseUser != null)
      .switchMap((firebaseUser) =>
          _roomRef.collection('participants').doc(firebaseUser.uid).snapshots())
      .map((doc) => doc.exists)
      .doOnData((isOnline) => _logger.fine('[isOnlineInRoom] $isOnline'));

  Future<bool> get leftRoom =>
      isOnlineInRoom.where((isOnline) => isOnline == false).first;

  Stream<List<String>> get pokerOptions =>
      room.map((room) => room?.pokerOptions ?? []);

  Future<void> submitVote() async {
    PerformanceService.instance.startTrace('submit_vote');
    final user = await _user;

    AnalyticsService.logSelectPokerOption(selectedPokerOption);

    final participant = RoomParticipant.fromUser(user);

    participant.vote = selectedPokerOption;

    // Now reset the option so it doesn't get stuck in the UI
    selectedPokerOption = null;

    await _roomRef
        .collection('participants')
        .doc(participant.id)
        .set(participant.toJson());

    return PerformanceService.instance.stopTrace("submit_vote");
  }

  Future<void> goOnline() async {
    _logger.fine('[goOnline] Wait for user...');
    UserCredential authResult;
    try {
      authResult = await FirebaseAuth.instance.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
    FirebaseAuth.instance.authStateChanges();
    assert(authResult != null);
    if (kIsWeb) {
      _logger.fine(
          '[goOnline] ${DatabaseService.instance.getOnlineStatusRefPath(authResult.user.uid)}');
      // await DatabaseService.instance.onDisconnectRemove(authResult.user.uid);
      return DatabaseService.instance
          .setOnlineStatus(authResult.user.uid, {'isOnline': true});
    }
  }

  Future<void> resetOnlineInRoom(BuildContext context) async {
    _logger.fine('[resetOnlineInRoom] $_roomId');
    PerformanceService.instance.startTrace('poker_participant_reset_online');
    var user = await _user.catchError((er) {});
    if (user == null || user.name == null) {
      await goOnline();
      user = await _user;
    }
    if (user.name == null) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => OnboardingScreen(roomId: _roomId)),
          (Route<dynamic> route) => false);
    }
    final participant = RoomParticipant.fromUser(user);
    final batch = FirebaseFirestore.instance.batch();
    batch.set(
      _roomRef.collection('participants').doc(participant.id),
      participant.toJson(),
    );
    batch.update(
      FirebaseFirestore.instance.collection('users').doc(user.id),
      user.toJson(),
    );

    await batch.commit();
    return PerformanceService.instance
        .stopTrace('poker_participant_reset_online');
  }

  Future<void> goOfflineInRoom() async {
    _logger.fine('[goOfflineInRoom] $_roomId');
    PerformanceService.instance.startTrace('poker_participant_go_offline');

    final user = await _user;
    _logger.fine('[goOfflineInRoom] removing $user from $_roomId');
    await _roomRef.collection('participants').doc(user.id).delete();

    return PerformanceService.instance
        .stopTrace('poker_participant_go_offline');
  }

  Future<PokerUser> get _user async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    return PokerUser.fromFirestore(userDoc);
  }

  void dispose() {
    isVotingOpenStreamController.close();
  }
}
