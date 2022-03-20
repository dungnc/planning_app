import 'package:agileplanning/definitions/theme_colors.constants.dart';
import 'package:flutter/material.dart';

final theme = ThemeData(
  brightness: Brightness.dark,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  backgroundColor: ThemeColors.appBackgroundPrimary,
  primaryColor: ThemeColors.primary,
  accentColor: ThemeColors.selected,
  textTheme: TextTheme(
    headline1: TextStyle(
      fontSize: 21,
      color: ThemeColors.gray,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.51,
    ),
    headline2: TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      letterSpacing: -0.34,
      color: ThemeColors.gray,
    ),
    headline3: TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 13,
      letterSpacing: -0.31,
      color: ThemeColors.primaryAlt,
    ),
    bodyText1: TextStyle(
      color: ThemeColors.primary,
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    button: TextStyle(
      fontSize: 17.0,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      letterSpacing: -0.41,
    ),
  ),
  primaryTextTheme: TextTheme(
    button: TextStyle(
      color: Color(0xffffffff),
      fontSize: 17.0,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      letterSpacing: -0.41,
    ),
  ),
  buttonTheme: ButtonThemeData(
    textTheme: ButtonTextTheme.primary,
    disabledColor: Colors.transparent,
  ),
);
