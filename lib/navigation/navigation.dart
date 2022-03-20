import 'dart:core';

import 'package:agileplanning/models/navigation_state.model.dart';
import 'package:agileplanning/navigation/routes.dart';
import 'package:agileplanning/screens/room_facilitate/room_facilitate.screen.dart';
import 'package:agileplanning/screens/okay/okay.screen.dart';
import 'package:agileplanning/screens/poker_offline/poker_offline.screen.dart';
import 'package:agileplanning/screens/poker_offline_vote/poker_offline_vote.screen.dart';
import 'package:agileplanning/screens/poker_online/poker_online.screen.dart';
import 'package:agileplanning/screens/room_create/room_create.screen.dart';
import 'package:agileplanning/screens/room_join/room_join.screen.dart';
import 'package:agileplanning/screens/error/route_not_found.screen.dart';
import 'package:agileplanning/screens/room_status_member/room_status_member.screen.dart';
import 'package:agileplanning/services/analytics.service.dart';
import 'package:agileplanning/services/logging.service.dart';
import 'package:agileplanning/services/performance.service.dart';
import 'package:flutter/material.dart';

class _ResolvedRoute {
  final String screenName;
  final Route<Widget> pageRoute;

  _ResolvedRoute.notFound(this.screenName) : pageRoute = null;

  _ResolvedRoute({@required this.screenName, @required this.pageRoute});
}

class AppNavigation {
  static final _log = LoggingService.withTag((AppNavigation).toString());
  static final Route<Widget> _routeNotFound = MaterialPageRoute(
    builder: (_) => RouteNotFoundScreen(),
  );

  static Route<Widget> handleRoute(RouteSettings settings) {
    _log.finest('[handleRoute] ${settings.name}');
    PerformanceService.instance.startTrace('routing');

    final resolvedRoute = _resolveRoute(settings);
    if (resolvedRoute == null) {
      return null;
    }
    final screenName = resolvedRoute.screenName;
    final route = resolvedRoute.pageRoute ?? _routeNotFound;
    final routeNotFound = resolvedRoute.pageRoute == null;

    PerformanceService.instance
        .putAttribute(trace: 'routing', attribute: 'route', value: screenName);

    PerformanceService.instance.stopTrace('routing');

    if (routeNotFound) {
      _log.error('[handleRoute] No route matching for: $route ($screenName)');
      throw ('No route matching for: $route ($screenName)');
    }

    AnalyticsService.setScreen(screenName);
    return route;
  }

  static _ResolvedRoute _resolveRoute(RouteSettings settings) {
    final route = settings.name;
    _log.finest('[_resolveRoute] $route');

    if (route.startsWith(AppRoutes.pokerSelection)) {
      return _ResolvedRoute(
        screenName: route,
        pageRoute: MaterialPageRoute(
          builder: (_) => PokerOfflineScreen(),
        ),
      );
    }

    if (route.startsWith(AppRoutes.okay)) {
      final params = settings.arguments as OkayScreenNavigationState;
      return _ResolvedRoute(
        screenName: route,
        pageRoute: MaterialPageRoute(
          builder: (_) => OkayScreen(
            title: params.title,
            buttonTitle: params.buttonTitle,
            timeout: params.timeout,
            nextRoute: params.nextRoute,
          ),
        ),
      );
    }
    if (route.startsWith(AppRoutes.pokerOfflineVotingDisplay)) {
      final params = settings.arguments as PokerOfflineOptionState;
      return _ResolvedRoute(
        screenName: route,
        pageRoute: MaterialPageRoute(
          builder: (_) => PokerOfflineVoteScreen(
            option: params.option,
          ),
        ),
      );
    }

    if (route == AppRoutes.roomOnlineCreate) {
      return _ResolvedRoute(
        screenName: route,
        pageRoute: MaterialPageRoute(
          builder: (_) => RoomCreateScreen(),
        ),
      );
    }

    if (route.startsWith(AppRoutes.roomOnlineJoin)) {
      final params = settings.arguments as PokerRoomNavigationState;
      final roomId = params?.roomId ?? AppRoutes.getRoomIdFromRoute(route);

      return _ResolvedRoute(
        screenName: roomId != null && roomId.isNotEmpty
            ? route.replaceFirst(roomId, '')
            : route,
        pageRoute: MaterialPageRoute(
          builder: (_) => RoomJoinScreen(
            roomId: roomId,
          ),
        ),
      );
    }

    if (route.startsWith(AppRoutes.roomOnlinePoker)) {
      final params = settings.arguments as PokerRoomNavigationState;
      final roomId = params?.roomId ?? AppRoutes.getRoomIdFromRoute(route);

      assert(roomId != null);
      assert(roomId.isNotEmpty);

      return _ResolvedRoute(
        screenName: route.replaceFirst("?roomId=$roomId", ''),
        pageRoute: MaterialPageRoute(
          builder: (_) => PokerOnlineScreen(
            roomId: roomId,
          ),
        ),
      );
    }

    if (route.startsWith(AppRoutes.roomOnlineFacilitate)) {
      final params = settings.arguments as PokerRoomNavigationState;
      final roomId = params?.roomId ?? AppRoutes.getRoomIdFromRoute(route);

      assert(roomId != null);
      assert(roomId.isNotEmpty);

      return _ResolvedRoute(
        screenName: route.replaceFirst(roomId, ''),
        pageRoute: MaterialPageRoute(
          builder: (_) => RoomFacilitateScreen(
            roomId: roomId,
          ),
        ),
      );
    }

    if (route.startsWith(AppRoutes.roomOnlineVotingStatus)) {
      final roomId = AppRoutes.getRoomIdFromRoute(route);

      assert(roomId != null);
      assert(roomId.isNotEmpty);

      return _ResolvedRoute(
        screenName: route.replaceFirst(roomId, ''),
        pageRoute: MaterialPageRoute(
          builder: (_) => RoomStatusMemberScreen(
            roomId: roomId,
          ),
        ),
      );
    }

    // return _ResolvedRoute.notFound(route);
    return null;
  }
}
