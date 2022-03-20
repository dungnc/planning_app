import 'package:agileplanning/models/navigation_state.model.dart';
import 'package:agileplanning/navigation/routes.dart';
import 'package:agileplanning/screens/onboarding/onboarding.screen.dart';
import 'package:agileplanning/screens/poker_offline/poker_offline.screen.dart';
import 'package:agileplanning/services/logging.service.dart';
import 'package:flutter/material.dart';

class RoutingService {
  // ignore: unused_field
  static final _logger = LoggingService.withTag((RoutingService).toString());

  /// Returns the routing state to home screen and removes all
  /// routes on the back-stack. The app will exit if the user
  /// press back from this state.
  static Future<void> resetToHomeScreen(BuildContext context) async {
    return Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
    // return Navigator.push(
    //     context, MaterialPageRoute(builder: (_) => OnboardingScreen()));
  }

  static Future<void> goToPokerSelection(BuildContext context) {
    return Navigator.of(context).pushReplacementNamed(
      AppRoutes.pokerSelection,
      // (route) => false,
    );
  }

  static Future<void> roomVotingStatus(BuildContext context, String roomId) {
    return Navigator.of(context).pushNamed(
      AppRoutes.roomOnlineVotingStatus + roomId,
    );
  }

  static Future<void> createPlanningRoom(BuildContext context) {
    return Navigator.of(context).pushNamed(
      AppRoutes.roomOnlineCreate,
    );
  }

  static Future<void> roomOnlineJoin(BuildContext context, [String roomId]) {
    return Navigator.of(context).pushNamed(
      AppRoutes.roomOnlineJoin,
      arguments: PokerRoomNavigationState(
        roomId: roomId,
      ),
    );
  }

  static Future<void> showOkayScreen(
    BuildContext context, {
    bool replace = false,
    String title,
    String buttonTitle,
    String nextRoute,
    int timeout,
  }) {
    final arguments = OkayScreenNavigationState(
      buttonTitle: buttonTitle,
      timeout: timeout,
      nextRoute: nextRoute,
      title: title,
    );

    if (replace) {
      return Navigator.of(context).pushReplacementNamed(
        AppRoutes.okay,
        arguments: arguments,
      );
    } else {
      return Navigator.of(context).pushNamed(
        AppRoutes.okay,
        arguments: arguments,
      );
    }
  }

  static Future<void> showOfflineOption(
    BuildContext context, {
    String option,
  }) {
    return Navigator.of(context).pushNamed(
      AppRoutes.pokerOfflineVotingDisplay,
      arguments: PokerOfflineOptionState(option: option),
    );
  }
}
