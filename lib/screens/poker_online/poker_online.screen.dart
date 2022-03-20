import 'package:agileplanning/blocs/poker_online.bloc.dart';
import 'package:agileplanning/components/buttons/button_primary.component.dart';
import 'package:agileplanning/components/poker/poker_grid.component.dart';
import 'package:agileplanning/components/scaffolds/scaffold_container.component.dart';
import 'package:agileplanning/definitions/theme_colors.constants.dart';
import 'package:agileplanning/dialogs/confirmation.dialog.dart';
import 'package:agileplanning/extensions/string.extension.dart';
import 'package:agileplanning/l10n/app_localizations.dart';
import 'package:agileplanning/services/analytics.service.dart';
import 'package:agileplanning/services/firebase_messaging.service.dart';
import 'package:agileplanning/services/logging.service.dart';
import 'package:agileplanning/services/routing.service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class PokerOnlineScreen extends StatefulWidget {
  final String roomId;

  const PokerOnlineScreen({
    Key key,
    @required this.roomId,
  }) : super(key: key);

  @override
  _PokerOnlineScreenState createState() => _PokerOnlineScreenState(roomId);
}

class _PokerOnlineScreenState extends State<PokerOnlineScreen> {
  final _log = LoggingService.withTag((_PokerOnlineScreenState).toString());
  final String roomId;
  final PokerOnlineBloc pokerOnlineBloc;

  _PokerOnlineScreenState(this.roomId)
      : pokerOnlineBloc = PokerOnlineBloc(roomId);

  @override
  void initState() {
    super.initState();
    pokerOnlineBloc.resetOnlineInRoom(context);
    // pokerOnlineBloc.leftRoom.then((_) => _wasRemovedFromRoom());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScaffoldWithContainer(
      body: WillPopScope(
        onWillPop: () => _leaveRoom(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                l10n.connectedToRoom().changeCasing(StringCasing.UpperCase),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    .copyWith(color: ThemeColors.secondary),
              ),
            ),
            GestureDetector(
              onTap: () => _leaveRoom(context),
              child: StreamBuilder<String>(
                stream: pokerOnlineBloc.roomId,
                initialData: widget.roomId,
                builder: (context, snapshot) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        snapshot.data,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headline3
                            .copyWith(color: ThemeColors.secondary),
                      ),
                      Icon(
                        Icons.exit_to_app,
                        color: ThemeColors.secondary,
                        size: Theme.of(context).textTheme.headline3.fontSize *
                            1.2,
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: StreamBuilder<List<String>>(
                  stream: pokerOnlineBloc.pokerOptions,
                  initialData: [],
                  builder: (_, snap) {
                    final options = snap.data ?? [];
                    return PokerGridComponent(
                      options: options,
                      selectedOption: pokerOnlineBloc.selectedPokerOption,
                      callbacks: options
                          .map(
                            (option) => () async {
                              setState(() {
                                pokerOnlineBloc.selectedPokerOption = option;
                              });
                            },
                          )
                          .toList(),
                    );
                  }),
            ),
            StreamBuilder<bool>(
              stream: pokerOnlineBloc.isVotingOpenStreamController.stream,
              builder: (context, snapshot) {
                final isVotingOpen = snapshot.data == true;
                final text = isVotingOpen
                    ? l10n.votingInProgress
                    : l10n.waitingForVotingRound;
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        text.changeCasing(StringCasing.UpperCase),
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headline3
                            .copyWith(color: ThemeColors.secondary),
                      ),
                    ),
                    ButtonPrimaryComponent(
                      title: l10n.ctaSubmitVote,
                      enabled: isVotingOpen && pokerOnlineBloc.hasSelection,
                      onPressed: () => _onSubmitVotePressed(context),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    pokerOnlineBloc.dispose();
    super.dispose();
  }

  /// Confirm with the user that he/she really wants to leave before
  /// exiting the room. This will remove the user as a participant in the
  /// room and will be reflected by all other room actors.
  Future<bool> _leaveRoom(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmationDialog.show(
      context: context,
      id: 'room_participant_leave',
      bodyText: l10n.questionLeaveRoomParticipant,
      titleButtonAccept: l10n.ctaLeaveRoomAccept,
      titleButtonDecline: l10n.ctaLeaveRoomDecline,
    );

    _log.fine('[_leaveRoom] Confirm leave: $confirmed');
    if (confirmed) {
      pokerOnlineBloc.goOfflineInRoom();
      RoutingService.goToPokerSelection(context);
    }

    return confirmed;
  }

  Future<void> _onSubmitVotePressed(BuildContext context) async {
    AnalyticsService.logButtonClick('poker_online_submit_vote');
    await pokerOnlineBloc.submitVote();
    return RoutingService.roomVotingStatus(context, roomId);
  }

  _wasRemovedFromRoom() {
    _log.fine('[_wasRemovedFromRoom]');
    if (context != null) {
      RoutingService.goToPokerSelection(context);
    }
  }
}
