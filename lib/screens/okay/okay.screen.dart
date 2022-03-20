import 'dart:async';

import 'package:agileplanning/components/scaffolds/scaffold_plain.component.dart';
import 'package:agileplanning/definitions/theme_colors.constants.dart';
import 'package:agileplanning/extensions/string.extension.dart';
import 'package:agileplanning/screens/okay/check_mark.component.dart';
import 'package:agileplanning/services/logging.service.dart';
import 'package:agileplanning/services/remote_config.service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OkayScreen extends StatefulWidget {
  final String title;
  final String buttonTitle;
  final String nextRoute;
  final int timeout;

  const OkayScreen({
    Key key,
    this.title,
    this.buttonTitle,
    this.nextRoute,
    this.timeout = 1000,
  }) : super(key: key);

  @override
  _OkayScreenState createState() => _OkayScreenState(timeout);
}

class _OkayScreenState extends State<OkayScreen> {
  final _logger = LoggingService.withTag((_OkayScreenState).toString());
  final int timeout;

  _OkayScreenState(this.timeout);

  @override
  void initState() {
    super.initState();
    final timeout = RemoteConfigService.instance.okayScreenSelfDismissTimeout;
    _logger.finer('[initState] Display okay screen for $timeout ms.');
    Future.delayed(Duration(milliseconds: timeout), _onDisplayTimeout);
  }

  _onDisplayTimeout() {
    final nextRoute = widget.nextRoute ?? '';
    if (nextRoute.isNotEmpty) {
      _logger.fine('[_onDisplayTimeout] Time is up. Going to: $nextRoute');
      Navigator.of(context).pushReplacementNamed(widget.nextRoute);
    } else {
      _logger.fine('[_onDisplayTimeout] Time is up. Popping screen.');
      Navigator.of(context).pop();
    }
  }

  Widget get titleWidget => widget.title?.isNotEmpty == true
      ? Text(
          widget.title.changeCasing(StringCasing.UpperCase),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 36.0,
            letterSpacing: -0.87,
            color: ThemeColors.primary,
          ),
        )
      : Container();

  @override
  Widget build(BuildContext context) {
    return ScaffoldPlain(
      body: Center(
        child: Container(
          width: kIsWeb ? 420 : MediaQuery.of(context).size.width,
          child: FractionallySizedBox(
            widthFactor: 0.66,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                titleWidget,
                CheckMarkComponent(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
