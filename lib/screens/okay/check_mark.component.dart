import 'package:agileplanning/components/svg/svg.component.dart';
import 'package:agileplanning/definitions/theme_colors.constants.dart';
import 'package:flutter/material.dart';

class CheckMarkComponent extends StatelessWidget {
  static const _size = 110.0;
  @override
  Widget build(BuildContext context) {
    return Container(
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
          path: 'assets/icons/done-black-48dp.svg',
          size: _size,
          color: ThemeColors.primary,
        ),
      ),
    );
  }
}
