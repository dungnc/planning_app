import 'package:agileplanning/services/logging.service.dart';

class AppRoutes {
  static final _logger = LoggingService.withTag((AppRoutes).toString());
  static const root = '/';
  static const pokerSelection = '/poker-selection/';
  static const okay = '/okay/';
  static const pokerOfflineVotingDisplay = '/voting/offline/display/';
  static const roomOnlineVotingStatus = '/planning/online/voting-status/';
  static const roomOnlineCreate = '/planning/online/create/';
  static const roomOnlinePoker = '/planning/online/vote/';
  static const roomOnlineJoin = '/planning/online/join/';
  static const roomOnlineFacilitate = '/planning/online/facilitate/';

  static String pokerOnlineWithRoomId(String roomId) {
    return roomOnlinePoker + roomId;
  }

  static String facilitateRoomWithId(String roomId) {
    return roomOnlineFacilitate + roomId;
  }

  static String getRoomIdFromRoute(String route) {
    _logger.finer('[getPlanningRoomIdFromRoute] $route');
    final match = RegExp(r'(\d{12})$').firstMatch(route);
    final roomId = match?.group(0);

    _logger.finer('[getPlanningRoomIdFromRoute] $roomId');
    return roomId;
  }
}
