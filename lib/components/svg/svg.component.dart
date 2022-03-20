import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgComponent extends StatelessWidget {
  final String path;
  final double size;
  final Color color;
  final bool allowDrawingOutsideViewBox;

  String get _path => path.replaceAll('assets/', 'assets/assets/');

  SvgComponent({
    this.path,
    this.size,
    this.color,
    this.allowDrawingOutsideViewBox,
  });

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? Image.network(
            _path,
            width: size,
            height: size,
            color: color,
          )
        : SvgPicture.asset(
            path,
            allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
            height: size,
            width: size,
            color: color,
          );
  }
}
