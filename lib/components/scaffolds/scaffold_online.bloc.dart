import 'package:agileplanning/models/room.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScaffoldOnlineBloc {
  final _roomId;

  ScaffoldOnlineBloc(this._roomId);

  DocumentReference get _roomRef =>
      FirebaseFirestore.instance.collection('rooms').doc(_roomId);

  Stream<Room> get room =>
      _roomRef.snapshots().map((snap) => Room.fromFirestore(snap));

  Stream<String> get roomId => room.map((room) => room?.formattedId);

  Stream<String> get host => room.map((room) => room?.ownerName);
}
