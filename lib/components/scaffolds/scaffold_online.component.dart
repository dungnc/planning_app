import 'package:agileplanning/components/buttons/button_tertiary.component.dart';
import 'package:agileplanning/components/scaffolds/scaffold_online.bloc.dart';
import 'package:agileplanning/definitions/theme_colors.constants.dart';
import 'package:agileplanning/l10n/app_localizations.dart';
import 'package:agileplanning/services/analytics.service.dart';
import 'package:flutter/material.dart';
import 'package:agileplanning/extensions/string.extension.dart';
import 'package:flutter/foundation.dart';

class ScaffoldOnline extends StatelessWidget {
  final Widget body;
  final String roomId;
  final String roomLink;
  final Function onSettingsPressed;
  final Function onRoomLeave;
  final Function onRoomCopy;
  final ScaffoldOnlineBloc scaffoldOnlineBloc;

  ScaffoldOnline({
    Key key,
    @required this.roomId,
    @required this.body,
    this.onRoomLeave,
    this.onSettingsPressed,
    this.onRoomCopy,
    this.roomLink,
  })  : scaffoldOnlineBloc = ScaffoldOnlineBloc(roomId),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Container(
          width: kIsWeb ? 420 : MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FlatButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              onRoomCopy();
                              // AnalyticsService.logButtonClick(
                              //     'app_bar_room_link_copy');
                              // Clipboard.setData(ClipboardData(
                              //     text:
                              //         "${l10n.roomColon(roomId)}\n${roomLink ?? ""}"));
                              // NotificationDialog.show(
                              //     context: context,
                              //     bodyText: l10n.savedToClipboard);
                              //https://meet.google.com/xrr-fqmo-hau
                              //Room ID: 524626000000
                              //Room Link: https://agileplanning.page.link/?link=https://agile-dev-84edb.firebaseapp.com/%23/planning/online/vote/?roomId%3D524626000000&apn=com.brainping.agileplanning.dev&afl=https://agileplanning.page.link/?link=https://agile-dev-84edb.firebaseapp.com/%23/planning/online/vote/?roomId%3D524626000000&isi=123456789&ibi=com.brainping.pokerplanner.dev&ifl=https://agileplanning.page.link/?link=https://agile-dev-84edb.firebaseapp.com/%23/planning/online/vote/?roomId%3D524626000000
                              //Room: 524626000000
                              //https://agileplanning.page.link/?link=https://agile-dev-84edb.firebaseapp.com/%23/planning/online/vote/?roomId%3D524626000000&apn=com.brainping.agileplanning.dev&afl=https://agileplanning.page.link/?link=https://agile-dev-84edb.firebaseapp.com/%23/planning/online/vote/?roomId%3D524626000000&isi=123456789&ibi=com.brainping.pokerplanner.dev&ifl=https://agileplanning.page.link/?link=https://agile-dev-84edb.firebaseapp.com/%23/planning/online/vote/?roomId%3D524626000000
                              // OptionDialog.show(
                              //     context: context,
                              //     titles: [l10n.copyRoomId, l10n.copyRoomLink],
                              //     onPresses: [
                              //       () {
                              //         AnalyticsService.logButtonClick(
                              //             'app_bar_room_id_copy');
                              //         Clipboard.setData(
                              //             ClipboardData(text: roomId));
                              //       },
                              //       () {
                              //         AnalyticsService.logButtonClick(
                              //             'app_bar_room_link_copy');
                              //         Clipboard.setData(ClipboardData(
                              //             text: scaffoldOnlineBloc
                              //                 .roomDynamicLinkForMobile));
                              //       },
                              //     ],
                              //     notificationTitle: l10n.savedToClipboard);
                              // AnalyticsService.logButtonClick(
                              //     'app_bar_room_id_copy');
                              // Clipboard.setData(ClipboardData(text: roomId));
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                StreamBuilder<String>(
                                  stream: scaffoldOnlineBloc.roomId,
                                  builder: (context, snapshot) => Text(
                                    l10n
                                        .roomColon(snapshot.data ?? '')
                                        .changeCasing(StringCasing.UpperCase),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline2
                                        .copyWith(color: ThemeColors.secondary),
                                  ),
                                ),
                                SizedBox(width: 10),
                                // Button copy room id
                                if (onRoomLeave != null)
                                  Icon(Icons.copy,
                                      size: 16, color: ThemeColors.secondary),
                              ],
                            ),
                          ),
                          StreamBuilder<String>(
                            stream: scaffoldOnlineBloc.host,
                            builder: (context, snapshot) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 10, top: 16),
                                child: Text(
                                  l10n
                                      .hostColon(snapshot.data ?? '')
                                      .changeCasing(StringCasing.UpperCase),
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline2
                                      .copyWith(color: ThemeColors.primary),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          onRoomLeave == null
                              ? Container(width: 100)
                              : ButtonTertiaryComponent(
                                  title: l10n.ctaLeaveRoom,
                                  small: true,
                                  onPressed: () {
                                    AnalyticsService.logButtonClick(
                                        'app_bar_room_leave');
                                    onRoomLeave();
                                  },
                                ),
                          if (onSettingsPressed != null)
                            ButtonTertiaryComponent(
                              title: l10n.ctaRoomSettings,
                              small: true,
                              onPressed: () {
                                AnalyticsService.logButtonClick(
                                    'app_bar_room_settings');
                                onSettingsPressed();
                              },
                            ),
                        ],
                      ),
                      Divider(
                        color: ThemeColors.primary,
                        height: 0,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  child: body,
                  padding: EdgeInsets.symmetric(
                    vertical: 30.0,
                    horizontal: 24.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
