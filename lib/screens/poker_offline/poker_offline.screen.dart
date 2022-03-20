import 'package:agileplanning/components/buttons/button_secondary.component.dart';
import 'package:agileplanning/components/poker/poker_grid.component.dart';
import 'package:agileplanning/components/scaffolds/scaffold_container.component.dart';
import 'package:agileplanning/definitions/theme_colors.constants.dart';
import 'package:agileplanning/extensions/string.extension.dart';
import 'package:agileplanning/l10n/app_localizations.dart';
import 'package:agileplanning/navigation/routes.dart';
import 'package:agileplanning/screens/poker_offline/poker_offline.bloc.dart';
import 'package:agileplanning/screens/poker_offline_settings/poker_offline_settings.dialog.dart';
import 'package:agileplanning/screens/room_join/room_join.bloc.dart';
import 'package:agileplanning/services/analytics.service.dart';
import 'package:agileplanning/services/logging.service.dart';
import 'package:agileplanning/services/routing.service.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PokerOfflineScreen extends StatefulWidget {
  @override
  _PokerOfflineScreenState createState() => _PokerOfflineScreenState();
}

class _PokerOfflineScreenState extends State<PokerOfflineScreen> {
  final _log = LoggingService.withTag((_PokerOfflineScreenState).toString());
  PokerOfflineBloc pokerOfflineBloc;

  //Define an async function to join a room with dynamic link
  void initDynamicLinks() async {
    await FirebaseDynamicLinks.instance.getInitialLink();
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;
      if (deepLink != null) {
        String roomId =
            pokerOfflineBloc.getRoomIdFromDeepLink(deepLink.toString());
        RoomJoinBloc roomJoinBloc = RoomJoinBloc();
        final l10n = AppLocalizations.of(context);

        bool _roomCanConnect = await roomJoinBloc.canConnectRoomId(roomId);
        if (_roomCanConnect) {
          AnalyticsService.logConnectToRoom(roomId);
          return RoutingService.showOkayScreen(
            context,
            title: l10n.success,
            replace: false,
            nextRoute: AppRoutes.pokerOnlineWithRoomId(roomId),
          );
        }
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      String roomId =
          pokerOfflineBloc.getRoomIdFromDeepLink(deepLink.toString());
      RoomJoinBloc roomJoinBloc = RoomJoinBloc();
      final l10n = AppLocalizations.of(context);

      bool _roomCanConnect = await roomJoinBloc.canConnectRoomId(roomId);
      if (_roomCanConnect) {
        AnalyticsService.logConnectToRoom(roomId);
        return RoutingService.showOkayScreen(
          context,
          title: l10n.success,
          replace: true,
          nextRoute: AppRoutes.pokerOnlineWithRoomId(roomId),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _log.finer('[initState]');
    initDynamicLinks();
    if (kIsWeb) {
      pokerOfflineBloc = PokerOfflineBloc();
    } else {
      pokerOfflineBloc = PokerOfflineBloc()..goOfflineInRooms();
    }
  }

  @override
  void dispose() {
    pokerOfflineBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScaffoldWithContainer(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FlatButton(
            onPressed: _onSettingsPressed,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.offlineMode.changeCasing(StringCasing.UpperCase),
                  style: Theme.of(context).textTheme.headline3,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.settings,
                    size: 16,
                    color: ThemeColors.primaryAlt,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: StreamBuilder<List<String>>(
              stream: pokerOfflineBloc.pokerOptions,
              builder: (context, snapshot) {
                final options = snapshot.data ?? [];
                return PokerGridComponent(
                  options: options,
                  callbacks: options
                      .map(
                        (option) => () async {
                          RoutingService.showOfflineOption(
                            context,
                            option: option,
                          );
                        },
                      )
                      .toList(),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                ButtonSecondaryComponent(
                  title: l10n.ctaConnectToRoom,
                  stringCase: StringCasing.Capitalize,
                  small: true,
                  horizontalPadding: MediaQuery.of(context).size.width * 0.03,
                  onPressed: () {
                    AnalyticsService.logButtonClick('connect_planning_room');
                    RoutingService.roomOnlineJoin(context);
                  },
                ),
                ButtonSecondaryComponent(
                  title: l10n.ctaFacilitateSession,
                  stringCase: StringCasing.Capitalize,
                  small: true,
                  onPressed: () {
                    AnalyticsService.logButtonClick('create_planning_room');
                    RoutingService.createPlanningRoom(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onSettingsPressed() {
    AnalyticsService.logButtonClick('offline_settings');
    PokerOfflineSettingsDialog.show(context);
  }
}
