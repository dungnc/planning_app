import 'package:agileplanning/definitions/theme_colors.constants.dart';
import 'package:agileplanning/definitions/theme_text_styles.constants.dart';
import 'package:agileplanning/extensions/string.extension.dart';
import 'package:flutter/material.dart';

class ButtonSecondaryComponent extends StatelessWidget {
  final String title;
  final Function onPressed;
  final bool enabled;
  final bool small;
  final StringCasing stringCase;
  final double horizontalPadding;

  const ButtonSecondaryComponent({
    Key key,
    @required this.onPressed,
    @required this.title,
    this.enabled = true,
    this.stringCase = StringCasing.UpperCase,
    this.small = false,
    this.horizontalPadding = 8,
  }) : super(key: key);

  get onPressedCallback => enabled ? onPressed : null;

  get buttonTextStyle => enabled
      ? ThemeTextStyles.buttonPrimaryEnabled
      : ThemeTextStyles.buttonPrimaryDisabled;

  get buttonBorderColor =>
      enabled ? ThemeColors.primary : ThemeColors.primary.withOpacity(0.75);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      elevation: 0.0,
      onPressed: onPressedCallback,
      padding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(small ? 30.0 : 40.0),
        side: BorderSide(
          color: buttonBorderColor,
          width: 0.75,
        ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: small ? 0 : double.infinity,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: small ? 4.0 : 24.0,
            horizontal: horizontalPadding,
          ),
          child: Text(
            title.changeCasing(stringCase),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.button.copyWith(
                  color: ThemeColors.primary,
                  fontSize: small ? 12.0 : 17.0,
                ),
          ),
        ),
      ),
    );
  }
}
