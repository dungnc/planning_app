import 'package:agileplanning/definitions/theme_colors.constants.dart';
import 'package:agileplanning/extensions/string.extension.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ButtonTertiaryComponent extends StatelessWidget {
  final String title;
  final Function onPressed;
  final bool enabled;
  final StringCasing stringCase;
  final bool small;

  const ButtonTertiaryComponent({
    Key key,
    @required this.onPressed,
    @required this.title,
    this.enabled = true,
    this.stringCase = StringCasing.UpperCase,
    this.small = false,
  }) : super(key: key);

  get onPressedCallback => enabled ? onPressed : null;

  get textColor =>
      enabled ? ThemeColors.primary : ThemeColors.primary.withOpacity(0.75);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onPressedCallback,
      visualDensity:
          small ? VisualDensity.compact : Theme.of(context).visualDensity,
      padding: small ? EdgeInsets.all(0.0) : null,
      child: AutoSizeText.rich(
        TextSpan(
          text: title.changeCasing(stringCase),
        ),
        style: Theme.of(context).textTheme.button.copyWith(
              color: textColor,
              fontSize: small ? 14.0 : 17.0,
            ),
        minFontSize: 12,
        maxLines: 1,
      ),
    );
  }
}
