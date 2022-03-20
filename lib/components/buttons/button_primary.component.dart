import 'package:agileplanning/definitions/theme_colors.constants.dart';
import 'package:agileplanning/definitions/theme_text_styles.constants.dart';
import 'package:agileplanning/extensions/string.extension.dart';
import 'package:agileplanning/services/logging.service.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ButtonPrimaryComponent extends StatefulWidget {
  final String title;
  final AsyncCallback onPressed;
  final bool enabled;
  final StringCasing stringCase;

  const ButtonPrimaryComponent({
    Key key,
    @required this.onPressed,
    @required this.title,
    this.enabled = true,
    this.stringCase = StringCasing.UpperCase,
  }) : super(key: key);

  @override
  _ButtonPrimaryComponentState createState() => _ButtonPrimaryComponentState();
}

class _ButtonPrimaryComponentState extends State<ButtonPrimaryComponent> {
  static final _log =
      LoggingService.withTag((_ButtonPrimaryComponentState).toString());
  static const _borderRadius = 40.0;

  bool _isProcessingPressed = false;

  get isEnabled =>
      widget.enabled && !_isProcessingPressed && widget.onPressed != null;

  get onPressedCallback {
    _log.finest('[onPressedCallback] isEnabled=$isEnabled');
    if (!isEnabled) {
      return null;
    }

    return () async {
      _log.finest('[onPressedCallback] Processing click');
      setState(() => _isProcessingPressed = true);
      await widget.onPressed();
      if (context != null) {
        setState(() => _isProcessingPressed = false);
      }
    };
  }

  get gradientColor => !widget.enabled
      ? null
      : LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment(3, 2),
          colors: [
            ThemeColors.gradientStart,
            ThemeColors.gradientEnd,
          ],
        );

  get buttonTextStyle => widget.enabled
      ? ThemeTextStyles.buttonPrimaryEnabled
      : ThemeTextStyles.buttonPrimaryDisabled;

  get buttonBorderColor => widget.enabled
      ? ThemeColors.buttonBorderEnabled
      : ThemeColors.buttonBorderDisabled;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      elevation: 0.0,
      onPressed: onPressedCallback,
      padding: EdgeInsets.all(0),
      textTheme: Theme.of(context).buttonTheme.textTheme,
      disabledColor: Colors.transparent,
      disabledTextColor: ThemeColors.buttonPrimaryDisabledText,
      disabledElevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: double.infinity,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_borderRadius),
            border: Border.all(
              color: widget.enabled ? Colors.transparent : buttonBorderColor,
              width: 0.5,
            ),
            gradient: gradientColor,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 24.0,
              horizontal: 16.0,
            ),
            child: AutoSizeText.rich(
              TextSpan(
                text: widget.title.changeCasing(widget.stringCase),
              ),
              style: buttonTextStyle,
              textAlign: TextAlign.center,
              minFontSize: 15,
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}
