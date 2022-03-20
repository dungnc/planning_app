import 'package:agileplanning/models/room.model.dart';
import 'package:agileplanning/services/logging.service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomJoinBloc {
  static final _logger = LoggingService.withTag((RoomJoinBloc).toString());

  Future<bool> canConnectRoomId(String roomId) async {
    _logger.fine('[checkRoomId] $roomId');

    final doc =
        await FirebaseFirestore.instance.collection('rooms').doc(roomId).get();

    if (!doc.exists) {
      _logger.fine('[checkRoomId] $roomId does not exist');
      return false;
    }

    return Room.fromFirestore(doc).isRoomOpen;
  }
}
