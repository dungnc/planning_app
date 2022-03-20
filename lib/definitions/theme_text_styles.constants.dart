import 'package:agileplanning/definitions/theme_colors.constants.dart';
import 'package:flutter/material.dart';

class ThemeTextStyles {
  static const button = TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    letterSpacing: -0.41,
  );

  static final buttonPrimaryDisabled = button.copyWith(
    color: ThemeColors.buttonPrimaryDisabledText,
  );

  static final buttonPrimaryEnabled = button.copyWith(
    color: ThemeColors.buttonPrimaryEnabledText,
  );

  static final buttonSecondaryDisabled = button.copyWith(
    color: ThemeColors.buttonPrimaryDisabledText,
  );

  static final buttonSecondaryEnabled = button.copyWith(
    color: ThemeColors.buttonPrimaryEnabledText,
  );

  static final pokerOption = TextStyle(
    fontSize: 36.0,
    color: ThemeColors.secondary,
    letterSpacing: -0.87,
  );

  static final avatarName = TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    letterSpacing: -0.41,
    color: Color(0x71ffffff),
  );

  static final roomCode = TextStyle(
    fontSize: 21,
    color: ThemeColors.gray,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.51,
  );
}
