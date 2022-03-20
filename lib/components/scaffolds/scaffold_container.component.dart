import 'package:agileplanning/blocs/user.bloc.dart';
import 'package:agileplanning/components/avatar/avatar.component.dart';
import 'package:agileplanning/definitions/theme_colors.constants.dart';
import 'package:agileplanning/definitions/theme_text_styles.constants.dart';
import 'package:agileplanning/models/user.model.dart';
import 'package:agileplanning/services/analytics.service.dart';
import 'package:agileplanning/services/routing.service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ScaffoldWithContainer extends StatelessWidget {
  final Widget body;
  static const _roundedCornerSize = 24.0;

  const ScaffoldWithContainer({
    Key key,
    @required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      // Avoid shrinking the UI when the keyboard comes up.
      // It only happens during onboarding input of name
      resizeToAvoidBottomInset: false,
      // use LayoutBuilder to set missing size and set Container width and heigth.
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
                  padding: EdgeInsets.only(
                    top: 16.0,
                    bottom: 8.0,
                  ),
                  child: SizedBox(
                    height: 100.0,
                    child: _UserProfileComponent(context),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: 40.0,
                    left: 20.0,
                    right: 20.0,
                  ),
                  child: Material(
                    elevation: 1.0,
                    borderRadius: BorderRadius.circular(
                      _roundedCornerSize,
                    ),
                    color: ThemeColors.appBackgroundSecondary,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: 8.0,
                        left: _roundedCornerSize * 1.25,
                        right: _roundedCornerSize * 1.25,
                      ),
                      child: body,
                    ),
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

class _UserProfileComponent extends StatelessWidget {
  final userBloc = UserBloc();
  final BuildContext buildContext;

  _UserProfileComponent(this.buildContext);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PokerUser>(
      stream: userBloc.currentUser,
      builder: (_, snap) {
        final user = snap.data;
        if (user == null) {
          return Container();
        }

        return Column(
          children: [
            if (user.avatar?.isEmpty == false)
              AvatarComponent(
                avatar: user.avatar,
                onPressed: () => _onAvatarPressed(buildContext, userBloc),
              ),
            if (user.name?.isEmpty == false)
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  user.name,
                  style: ThemeTextStyles.avatarName,
                ),
              ),
          ],
        );
      },
    );
  }

  static void _onAvatarPressed(BuildContext context, UserBloc bloc) {
    AnalyticsService.logButtonClick('top_screen_avatar');
    RoutingService.resetToHomeScreen(context);
    return bloc.resetOnboarding();
  }
}
