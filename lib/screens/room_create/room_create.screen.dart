import 'package:agileplanning/components/buttons/button_primary.component.dart';
import 'package:agileplanning/components/buttons/button_secondary.component.dart';
import 'package:agileplanning/components/buttons/button_tertiary.component.dart';
import 'package:agileplanning/components/scaffolds/scaffold_plain.component.dart';
import 'package:agileplanning/definitions/theme_colors.constants.dart';
import 'package:agileplanning/definitions/theme_text_styles.constants.dart';
import 'package:agileplanning/extensions/string.extension.dart';
import 'package:agileplanning/l10n/app_localizations.dart';
import 'package:agileplanning/navigation/routes.dart';
import 'package:agileplanning/screens/room_create/room_create.bloc.dart';
import 'package:agileplanning/services/analytics.service.dart';
import 'package:agileplanning/services/routing.service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RoomCreateScreen extends StatefulWidget {
  @override
  _RoomCreateScreenState createState() => _RoomCreateScreenState();
}

class _RoomCreateScreenState extends State<RoomCreateScreen> {
  final roomCreateBloc = RoomCreateBloc();
  @override
  void initState() {
    super.initState();
    roomCreateBloc.touchRoom();
  }

  @override
  void dispose() {
    roomCreateBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ScaffoldPlain(
      body: Center(
        child: Container(
          width: kIsWeb ? 420 : MediaQuery.of(context).size.width,
          child: FractionallySizedBox(
            widthFactor: 0.75,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  l10n.screenTitleCreatePlanningRoom
                      .changeCasing(StringCasing.Capitalize),
                  style: Theme.of(context).textTheme.headline1,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.0),
                Text(
                  l10n.screenSubTitleCreatePlanningRoom
                      .changeCasing(StringCasing.Capitalize),
                  style: Theme.of(context).textTheme.headline2,
                  textAlign: TextAlign.center,
                ),
                Spacer(flex: 1),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: ThemeColors.primary,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 24.0,
                    ),
                    child: StreamBuilder<String>(
                      stream: roomCreateBloc.roomCode,
                      initialData: RoomCreateBloc.placeholderCode,
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data,
                          textAlign: TextAlign.center,
                          style: ThemeTextStyles.roomCode,
                        );
                      },
                    ),
                  ),
                ),
                StreamBuilder<bool>(
                  stream: roomCreateBloc.isRoomReady,
                  builder: (context, snapshot) {
                    return ButtonTertiaryComponent(
                      title: l10n.ctaGenerateRoomId,
                      enabled: snapshot.data == true,
                      onPressed: () {
                        AnalyticsService.logButtonClick('generate_new_room_id');
                        roomCreateBloc.regenerate();
                      },
                    );
                  },
                ),
                SizedBox(height: 8.0),
                StreamBuilder<bool>(
                  stream: roomCreateBloc.isRoomReady,
                  builder: (context, snapshot) {
                    return ButtonPrimaryComponent(
                      title: l10n.ctaCreatePlanningRoom,
                      enabled: snapshot.data == true,
                      onPressed: () async {
                        AnalyticsService.logButtonClick('facilitate_room');
                        final room = await roomCreateBloc.room.first;
                        RoutingService.showOkayScreen(
                          context,
                          replace: true,
                          title: l10n.promptPlanningRoomCreated,
                          nextRoute: AppRoutes.facilitateRoomWithId(room.id),
                        );
                      },
                    );
                  },
                ),
                Spacer(flex: 1),
                ButtonSecondaryComponent(
                  title: l10n.ctaBack,
                  small: false,
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
