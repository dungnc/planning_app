import 'package:agileplanning/app.dart';
import 'package:agileplanning/definitions/build_flavor.enum.dart';
import 'package:flutter/material.dart';
import 'app_info.dart';

void main() {
  AppInfo.buildFlavor = BuildFlavor.Production;
  runApp(MyApp());
}
