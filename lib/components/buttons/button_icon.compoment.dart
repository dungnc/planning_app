import 'package:flutter/material.dart';

class ButtonIconComponent extends StatelessWidget {
  final Widget icon;
  final Function onPressed;

  const ButtonIconComponent({
    Key key,
    @required this.onPressed,
    @required this.icon,
  }) : super(key: key);

  get onPressedCallback => onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: icon,
      onTap: onPressedCallback,
    );
  }
}
