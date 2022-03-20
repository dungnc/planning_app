import 'package:agileplanning/definitions/build_flavor.enum.dart';

class AppInfo {
  static BuildFlavor buildFlavor;

  static String get title {
    switch (buildFlavor) {
      case BuildFlavor.Development:
        return '[D] Agile planning';
      case BuildFlavor.Production:
      default:
        return 'Agile planning';
    }
  }
}
