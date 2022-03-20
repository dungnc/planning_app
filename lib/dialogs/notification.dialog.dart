import 'dart:async';

import 'package:agileplanning/definitions/theme_colors.constants.dart';
import 'package:agileplanning/extensions/string.extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NotificationDialog extends StatelessWidget {
  final String bodyText;

  const NotificationDialog({
    Key key,
    @required this.bodyText,
  }) : super(key: key);

  static show({
    @required BuildContext context,
    @required String bodyText,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => NotificationDialog(
        bodyText: bodyText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pop(true);
    });
    return AlertDialog(
      backgroundColor: ThemeColors.appBackgroundSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      content: Container(
        width: kIsWeb ? 420 : MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Text(
              bodyText.changeCasing(StringCasing.UpperCase),
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
