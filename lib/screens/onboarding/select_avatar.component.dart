import 'package:agileplanning/blocs/user.bloc.dart';
import 'package:agileplanning/components/avatar/avatar.component.dart';
import 'package:agileplanning/components/buttons/button_primary.component.dart';
import 'package:agileplanning/extensions/string.extension.dart';
import 'package:agileplanning/l10n/app_localizations.dart';
import 'package:agileplanning/screens/onboarding/onboarding.bloc.dart';
import 'package:agileplanning/services/analytics.service.dart';
import 'package:agileplanning/services/logging.service.dart';
import 'package:flutter/material.dart';

class OnboardingSelectAvatarComponent extends StatefulWidget {
  @override
  _OnboardingSelectAvatarComponentState createState() =>
      _OnboardingSelectAvatarComponentState();
}

class _OnboardingSelectAvatarComponentState
    extends State<OnboardingSelectAvatarComponent> {
  final _log = LoggingService.withTag(
      (_OnboardingSelectAvatarComponentState).toString());
  final userBloc = UserBloc();
  final avatarSelectionBloc = OnboardingBloc();

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 300), _onDisplayTimeout);
  }

  /// Animate a small scroll and bounce-back on the avatar selection to
  /// hint to the user that the view is scrollable and that there are
  /// more avatars to select from.
  _onDisplayTimeout() async {
    _log.finest('[display timeout]');
    _scrollController.jumpTo(250);
    await _scrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 24.0, top: 8),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    direction: Axis.vertical,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 24.0,
                    children: [
                      Text(
                        l10n.onboardingScreenTitle,
                        style: Theme.of(context).textTheme.headline1,
                      ),
                      Text(
                        l10n.onboardingScreenSubtitleAvatar
                            .changeCasing(StringCasing.UpperCase),
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    direction: Axis.horizontal,
                    runSpacing: 16.0,
                    spacing: -10.0,
                    children: avatarSelectionBloc.avatars
                        .map(
                          (avatar) => AvatarComponent(
                            avatar: avatar,
                            onPressed: () {
                              setState(() {
                                avatarSelectionBloc.selectedAvatar = avatar;
                              });
                            },
                            isSelected:
                                avatarSelectionBloc.isSelectedAvatar(avatar),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: ButtonPrimaryComponent(
            onPressed: () async {
              AnalyticsService.logOnboardingStep('avatar');
              avatarSelectionBloc.saveAvatar();
            },
            title: l10n.ctaContinue,
            stringCase: StringCasing.Capitalize,
            enabled: avatarSelectionBloc.hasSelectedAvatar,
          ),
        ),
      ],
    );
  }
}
