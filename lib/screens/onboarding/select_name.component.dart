import 'package:agileplanning/blocs/user.bloc.dart';
import 'package:agileplanning/components/buttons/button_primary.component.dart';
import 'package:agileplanning/dialogs/confirmation.dialog.dart';
import 'package:agileplanning/dialogs/notification.dialog.dart';
import 'package:agileplanning/extensions/string.extension.dart';
import 'package:agileplanning/l10n/app_localizations.dart';
import 'package:agileplanning/navigation/routes.dart';
import 'package:agileplanning/screens/onboarding/onboarding.bloc.dart';
import 'package:agileplanning/services/analytics.service.dart';
import 'package:agileplanning/services/firebase_messaging.service.dart';
import 'package:agileplanning/services/logging.service.dart';
import 'package:agileplanning/services/routing.service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

enum _ValidationError {
  Ok,
  EmptyName,
  MinLength,
  MaxLength,
}

class OnboardingSelectNameComponent extends StatefulWidget {
  final BuildContext context;
  final String roomId;

  const OnboardingSelectNameComponent({Key key, this.roomId, this.context})
      : super(key: key);
  @override
  _OnboardingSelectNameComponentState createState() =>
      _OnboardingSelectNameComponentState();
}

class _OnboardingSelectNameComponentState
    extends State<OnboardingSelectNameComponent> {
  static final _log =
      LoggingService.withTag((_OnboardingSelectNameComponentState).toString());
  final userBloc = UserBloc();
  final nameSelectionBloc = OnboardingBloc();

  final _formKey = GlobalKey<FormState>();
  bool _continueEnabled = false;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onTextChange);
  }

  @override
  Widget build(BuildContext context) {
    _log.finest('[build]');
    final l10n = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                          l10n.onboardingScreenSubtitleName
                              .changeCasing(StringCasing.UpperCase),
                          style: Theme.of(context).textTheme.headline2,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      autovalidateMode: AutovalidateMode.always,
                      keyboardType: TextInputType.text,
                      maxLength: 25,
                      onChanged: (value) =>
                          nameSelectionBloc.selectedName = value,
                      validator: (value) => _validateName(l10n, value),
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
                AnalyticsService.logOnboardingStep('name');
                nameSelectionBloc.saveName();
                await FirebaseMessaging.instance
                    .getNotificationSettings()
                    .then((setting) async {
                  if (setting.authorizationStatus !=
                      AuthorizationStatus.authorized) {
                    await ConfirmationDialog.show(
                            id: 'notification_permission_request',
                            context: context,
                            bodyText:
                                "Let us notify you when things happen in your team room",
                            titleButtonAccept: l10n.ctaAccept,
                            titleButtonDecline: "Decline")
                        .then((value) {
                      if (value != null && value) {
                        FirebaseMessageService().initNotification(context);
                      }
                      // FirebaseMessageService().initNotification(context);
                      if (widget.roomId != null) {
                        RoutingService.showOkayScreen(widget.context,
                            replace: false,
                            title: l10n.success,
                            nextRoute:
                                AppRoutes.pokerOnlineWithRoomId(widget.roomId));
                      } else {
                        RoutingService.showOkayScreen(widget.context,
                            nextRoute: AppRoutes.root);
                      }
                    });
                  }
                });
              },
              title: l10n.ctaContinue,
              stringCase: StringCasing.Capitalize,
              enabled: _continueEnabled,
            ),
          ),
        ],
      ),
    );
  }

  _onTextChange() {
    final name = _nameController.text;
    final isValid = _getValidationState(name) == _ValidationError.Ok;

    _log.finer('[_onTextChanged] $name => $isValid');
    setState(() {
      _continueEnabled = isValid;
    });
  }

  _getValidationState(String name) {
    if (name == null || name.isEmpty) {
      return _ValidationError.EmptyName;
    }

    if (name.length < OnboardingBloc.minLengthName) {
      return _ValidationError.MinLength;
    }

    if (name.length > OnboardingBloc.maxLengthName) {
      return _ValidationError.MaxLength;
    }

    return _ValidationError.Ok;
  }

  String _validateName(AppLocalizations l10n, String name) {
    _log.fine('[validateName] $name');

    switch (_getValidationState(name)) {
      case _ValidationError.EmptyName:
        return l10n.formValidationErrorNameEmpty;
      case _ValidationError.MinLength:
        return l10n.formValidationErrorNameEmpty;
      case _ValidationError.MaxLength:
        return l10n.formValidationErrorNameTooLong;
      case _ValidationError.Ok:
      default:
        return null;
    }
  }
}
