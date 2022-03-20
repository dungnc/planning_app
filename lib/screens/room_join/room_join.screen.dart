import 'package:agileplanning/components/buttons/button_primary.component.dart';
import 'package:agileplanning/components/buttons/button_secondary.component.dart';
import 'package:agileplanning/components/scaffolds/scaffold_plain.component.dart';
import 'package:agileplanning/definitions/theme_colors.constants.dart';
import 'package:agileplanning/definitions/theme_text_styles.constants.dart';
import 'package:agileplanning/extensions/string.extension.dart';
import 'package:agileplanning/l10n/app_localizations.dart';
import 'package:agileplanning/models/room.model.dart';
import 'package:agileplanning/navigation/routes.dart';
import 'package:agileplanning/screens/room_join/room_join.bloc.dart';
import 'package:agileplanning/services/analytics.service.dart';
import 'package:agileplanning/services/logging.service.dart';
import 'package:agileplanning/services/routing.service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

enum _ValidationError {
  Ok,
  Empty,
  WrongLength,
  CanNotConnect,
  OnlyDigits,
}

class RoomJoinScreen extends StatefulWidget {
  final String roomId;

  RoomJoinScreen({
    Key key,
    this.roomId,
  }) : super(key: key);

  @override
  _RoomJoinScreenState createState() => _RoomJoinScreenState();
}

class _RoomJoinScreenState extends State<RoomJoinScreen> {
  static final _logger =
      LoggingService.withTag((_RoomJoinScreenState).toString());
  final _roomIdController = TextEditingController();
  final _bloc = RoomJoinBloc();
  final _formKey = GlobalKey<FormState>();
  String _enteredRoomId;

  bool _continueEnabled = false;
  bool _keyboardHidden = true;
  bool _roomCanConnect = true;

  @override
  void initState() {
    super.initState();
    _roomIdController.addListener(_onTextChange);
    KeyboardVisibilityNotification().addNewListener(
      onShow: () => setState(() => _keyboardHidden = false),
      onHide: () => setState(() => _keyboardHidden = true),
    );
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
                  l10n.screenTitleConnectRoom
                      .changeCasing(StringCasing.Capitalize),
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
                if (_keyboardHidden)
                  Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Text(
                      l10n.screenSubtitleConnectRoom
                          .changeCasing(StringCasing.Capitalize),
                      style: Theme.of(context).textTheme.bodyText1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _roomIdController,
                          textCapitalization: TextCapitalization.none,
                          maxLength: Room.idLength +
                              3, //In each 3 number can have a whitespace
                          initialValue: widget.roomId,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: ThemeTextStyles.roomCode,
                          decoration: InputDecoration(
                            errorMaxLines: 4,
                            counterText:
                                '', // Removes the character count under widget
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2),
                              borderSide: BorderSide(
                                color: ThemeColors.primary,
                                width: 1.0,
                              ),
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) => _validateRoomId(l10n, value),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: ButtonPrimaryComponent(
                          title: l10n.ctaConnect,
                          enabled: _continueEnabled,
                          onPressed: () => _onConnectToRoomPressed(l10n),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_keyboardHidden)
                  ButtonSecondaryComponent(
                    title: l10n.ctaBack,
                    onPressed: _onBackButtonPressed,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _onBackButtonPressed() {
    AnalyticsService.logButtonClick('connect_to_room_back');
    Navigator.of(context).pop();
  }

  Future<void> _onConnectToRoomPressed(AppLocalizations l10n) async {
    _logger.fine('[_onConnectToRoomPressed] $_enteredRoomId');
    AnalyticsService.logButtonClick('connect_to_room_connect');
    _enteredRoomId = _enteredRoomId.replaceAll(" ", "");
    _roomCanConnect = await _bloc.canConnectRoomId(_enteredRoomId);

    if (_roomCanConnect) {
      AnalyticsService.logConnectToRoom(_enteredRoomId);
      return RoutingService.showOkayScreen(
        context,
        title: l10n.success,
        replace: true,
        nextRoute: AppRoutes.pokerOnlineWithRoomId(_enteredRoomId),
      );
    }

    _formKey.currentState.validate();
    setState(() {
      _continueEnabled = false;
    });
  }

  _onTextChange() {
    final roomId = _roomIdController.text;
    final isValid = _getValidationState(roomId) == _ValidationError.Ok;

    _logger.finer('[_onTextChanged] $roomId => $isValid');
    setState(() {
      _roomCanConnect = true;
      _continueEnabled = isValid;
      _enteredRoomId = roomId;
    });
  }

  _getValidationState(String roomId) {
    roomId = roomId.replaceAll(" ", "");
    if (roomId == null || roomId.isEmpty) {
      return _ValidationError.Empty;
    }

    if (RegExp(r"^\d+").firstMatch(roomId) == null) {
      return _ValidationError.OnlyDigits;
    }

    if (roomId.replaceAll(" ", "").length != Room.idLength) {
      return _ValidationError.WrongLength;
    }

    if (!_roomCanConnect) {
      return _ValidationError.CanNotConnect;
    }

    return _ValidationError.Ok;
  }

  String _validateRoomId(AppLocalizations l10n, String roomId) {
    _logger.fine('[_validateRoomCode] $roomId');

    switch (_getValidationState(roomId)) {
      case _ValidationError.Empty:
        return l10n.formValidationErrorNotEmpty;
      case _ValidationError.OnlyDigits:
        return l10n.formValidationErrorOnlyDigits;
      case _ValidationError.WrongLength:
        return l10n.formValidationErrorRoomIdLength;
      case _ValidationError.CanNotConnect:
        return l10n.formValidationErrorRoomCanNotConnect;
      case _ValidationError.Ok:
      default:
        return null;
    }
  }
}
