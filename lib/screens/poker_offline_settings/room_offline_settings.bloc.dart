import 'dart:async';

import 'package:agileplanning/definitions/poker.constants.dart';
import 'package:agileplanning/models/room.model.dart';
import 'package:agileplanning/models/room_participant.model.dart';
import 'package:agileplanning/services/logging.service.dart';
import 'package:agileplanning/services/performance.service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/subjects.dart';

class RoomOfflineSettingsBloc {
  static const _numStartingOptions = 12;
  final _log = LoggingService.withTag((RoomOfflineSettingsBloc).toString());
  final String _roomId;
  final _numOptionsMax = _numStartingOptions;
  final _pokerOptions = List.generate(_numStartingOptions, (_) => '');
  final _pokerOpts = BehaviorSubject.seeded(pokerOptsDefault.toList());
  final _subscriptions = List<StreamSubscription>();

  DocumentReference get _roomRef =>
      FirebaseFirestore.instance.collection('rooms').doc(_roomId);

  Stream<Room> get _room =>
      _roomRef.snapshots().map((snap) => Room.fromFirestore(snap));

  RoomOfflineSettingsBloc(this._roomId) {
    _subscriptions.add(_room
        .map((room) => room?.pokerOptions ?? [])
        .listen((opts) => _pokerOpts.add(opts)));
  }

  void dispose() {
    _log.fine('[dispose]');
    _pokerOpts.close();
    _subscriptions.forEach((subscription) => subscription?.cancel());
  }

  void presetFibonacci() {
    _log.fine('[presetFibonacci]');
    _pokerOpts.add(pokerOptsFibonacci.toList());
  }

  void presetTshirt() {
    _log.fine('[presetTshirt]');
    _pokerOpts.add(pokerOptsTshirt.toList());
  }

  /// Returns a streamed list of 12 poker options
  /// The list is constantly containing 12 elements as the stream will put in
  /// additional empty option values if there are less than 12 in the actual
  /// list.
  Stream<List<String>> get pokerOptions => _pokerOpts.map((options) {
        final numOptsToGenerate = _numOptionsMax - options.length;
        final extraOpts = List.generate(numOptsToGenerate, (_) => '');

        // Extend the options array to ensure minimum length
        options.insertAll(options.length, extraOpts);

        // Update the local copy of poker options
        _pokerOptions.setAll(0, options);

        return options;
      });

  /// Update the poker option at a certain position
  void setPokerOption(int index, String value) {
    _log.fine('[setPokerOption] value: $value, index: $index');
    assert(index < _pokerOptions.length);
    _pokerOptions[index] = value.trim();
  }

  /// Saves all the room settings
  Future<void> saveSettings() {
    _log.fine('[save]');
    return _roomRef.update({
      'pokerOptions': _pokerOptions
          .map((opt) => opt.trim())
          .where((opt) => opt.isNotEmpty)
          .toList(),
    });
  }

  Future<void> destroyRoom() async {
    _log.fine('[destroyRoom] $_roomId');
    PerformanceService.instance.startTrace('destroy_room');

    final snap = await _roomRef.collection('participants').get();
    final batch = FirebaseFirestore.instance.batch();
    for (var doc in snap.docs) {
      final participant = RoomParticipant.fromFirestore(doc);
      _log.finer('[destroyRoom] Removing $participant');
      batch.delete(doc.reference);
    }

    final roomDoc = await _roomRef.get();
    assert(roomDoc.exists);

    final room = Room.fromFirestore(roomDoc)..destroy();
    batch.update(_roomRef, room.toJson());

    await batch.commit();

    return PerformanceService.instance.stopTrace('destroy_room');
  }
}
