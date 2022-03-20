import 'package:agileplanning/blocs/user.bloc.dart';
import 'package:agileplanning/components/scaffolds/scaffold_container.component.dart';
import 'package:agileplanning/l10n/app_localizations.dart';
import 'package:agileplanning/models/user.model.dart';
import 'package:agileplanning/navigation/routes.dart';
import 'package:agileplanning/screens/onboarding/onboarding.bloc.dart';
import 'package:agileplanning/screens/onboarding/select_avatar.component.dart';
import 'package:agileplanning/screens/onboarding/select_name.component.dart';
import 'package:agileplanning/screens/room_join/room_join.bloc.dart';
import 'package:agileplanning/services/analytics.service.dart';
import 'package:agileplanning/services/routing.service.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  final String roomId;

  const OnboardingScreen({Key key, this.roomId}) : super(key: key);
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final userBloc = UserBloc();
  final onboardingBloc = OnboardingBloc();

  @override
  void initState() {
    super.initState();
    onboardingBloc.touchUser();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithContainer(
      body: StreamBuilder<PokerUser>(
        stream: userBloc.currentUser,
        builder: (_, snap) {
          final user = snap.data;
          if (user?.avatar == null) {
            return OnboardingSelectAvatarComponent();
          }

          if (user?.name == null) {
            return OnboardingSelectNameComponent(
              context: context,
              roomId: widget.roomId,
            );
          }

          return Container();
        },
      ),
    );
  }
}
