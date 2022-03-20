import 'package:agileplanning/components/svg/svg.component.dart';
import 'package:agileplanning/definitions/theme_colors.constants.dart';
import 'package:flutter/material.dart';

class ButtonDismissComponent extends StatelessWidget {
  final double size;
  final Function onPressed;

  const ButtonDismissComponent({
    Key key,
    @required this.size,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      shape: CircleBorder(),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: ThemeColors.primary,
            width: 2.0,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: SvgComponent(
            path: 'assets/icons/clear-black-48dp.svg',
            size: size,
            color: ThemeColors.primary,
          ),
        ),
      ),
    );
  }
}
