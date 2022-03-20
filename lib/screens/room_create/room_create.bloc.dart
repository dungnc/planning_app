import 'package:agileplanning/models/room.model.dart';
import 'package:agileplanning/models/user.model.dart';
import 'package:agileplanning/services/logging.service.dart';
import 'package:agileplanning/services/performance.service.dart';
import 'package:agileplanning/services/remote_config.service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class RoomCreateBloc {
  static const placeholderCode = '--- --- --- ---';
  final _logger = LoggingService.withTag((RoomCreateBloc).toString());
  final _roomCode = BehaviorSubject<String>.seeded(placeholderCode);

  Stream<String> get roomCode => _roomCode.stream;

  Stream<bool> get isRoomReady =>
      _roomCode.map((code) => code != placeholderCode);

  dispose() {
    _roomCode.close();
  }

  Stream<Room> get room => Stream.value(FirebaseAuth.instance.currentUser)
      .switchMap(
          (firebaseUser) => _getUserRoomRef(firebaseUser.uid).snapshots())
      .where((snap) => snap.docs.length > 0)
      .map((snap) => Room.fromFirestore(snap.docs.first))
      .defaultIfEmpty(null);

  Future<void> touchRoom() async {
    _logger.fine('[touchRoom]');
    PerformanceService.instance.startTrace('offline_all_rooms');
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final rooms = await _getUserRoomRef(firebaseUser.uid).get();

    if (rooms.docs.length == 0) {
      PerformanceService.instance.putAttribute(
          trace: 'offline_all_rooms', attribute: 'existing', value: 'no');
      PerformanceService.instance.putAttribute(
          trace: 'offline_all_rooms', attribute: 'force_closed', value: 'no');
      await createRoom();
    } else {
      final room = Room.fromFirestore(rooms.docs.first);

      // Emit the room code to the stream
      _updateRoomCode(room);

      // Info
      PerformanceService.instance.putAttribute(
          trace: 'offline_all_rooms', attribute: 'existing', value: 'yes');
      _logger.fine('[touchRoom] $room');

      // Close the room to ensure that we are consistent with the screen's
      // purpose and usage to "create and open a room"
      if (room.isRoomOpen) {
        _logger.fine('[touchRoom] Force closing $room');
        PerformanceService.instance.putAttribute(
            trace: 'offline_all_rooms',
            attribute: 'force_closed',
            value: 'yes');
        room.close();
        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(room.id)
            .set(room.toJson());
      }
    }

    return PerformanceService.instance.stopTrace('offline_all_rooms');
  }

  Future<void> createRoom() async {
    PerformanceService.instance.startTrace('create_room');
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();
    assert(userDoc.exists);

    final userName = PokerUser.fromFirestore(userDoc).name;
    final pokerOptions = RemoteConfigService.instance.pokerOptions;

    while (true) {
      final room = Room(
        owner: firebaseUser.uid,
        ownerName: userName,
        pokerOptions: pokerOptions,
      );
      final ref = FirebaseFirestore.instance.collection('rooms').doc(room.id);
      PerformanceService.instance
          .incrementMetric(trace: 'create_room', metric: 'attempts', value: 1);
      final existingRoom = await ref.get();
      if (existingRoom.exists == false) {
        _logger.fine('[createRoom] $room');
        _updateRoomCode(room);
        await ref.set(room.toJson());
        return PerformanceService.instance.stopTrace('create_room');
      } else {
        _logger.fine('[createRoom] Room already exist: $room');
      }
    }
  }

  Future<void> regenerate() async {
    _logger.fine('[regenerate]');
    PerformanceService.instance.startTrace('regenerate_room_id');
    _updateRoomCode();

    final firebaseUser = FirebaseAuth.instance.currentUser;
    final rooms = await _getUserRoomRef(firebaseUser.uid).get();

    final batch = FirebaseFirestore.instance.batch();

    for (final doc in rooms.docs) {
      final room = Room.fromFirestore(doc)..destroy();
      _logger.fine('[regenerate] Destroy $room');
      batch.set(
        FirebaseFirestore.instance.collection('rooms').doc(room.id),
        room.toJson(),
      );
    }
    await batch.commit();
    await createRoom();
    return PerformanceService.instance.stopTrace('regenerate_room_id');
  }

  _updateRoomCode([Room room]) {
    if (_roomCode.isClosed) {
      return;
    }

    final formattedId = room?.formattedId ?? placeholderCode;
    _logger.finer('[_updateRoomCode] $formattedId');
    _roomCode.add(formattedId);
  }

  Query _getUserRoomRef(String uid) => FirebaseFirestore.instance
      .collection('rooms')
      .where('owner', isEqualTo: uid)
      .where('isDestroyed', isEqualTo: false);
}
