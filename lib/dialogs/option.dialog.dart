import 'package:agileplanning/components/buttons/button_primary.component.dart';
import 'package:agileplanning/definitions/theme_colors.constants.dart';
import 'package:flutter/material.dart';

import 'notification.dialog.dart';

class OptionDialog extends StatelessWidget {
  final List<String> titles;
  final List<Function> onPresses;
  final String notificationTitle;
  const OptionDialog(
      {Key key,
      @required this.titles,
      @required this.onPresses,
      @required this.notificationTitle})
      : assert(titles.length == onPresses.length,
            "titles length and onPresses length must be equal"),
        super(key: key);

  static show(
      {@required BuildContext context,
      @required List<String> titles,
      @required List<Function> onPresses,
      @required String notificationTitle}) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => OptionDialog(
        titles: titles,
        onPresses: onPresses,
        notificationTitle: notificationTitle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ThemeColors.appBackgroundSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      content: Padding(
        padding: EdgeInsets.all(16.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: titles.length == 1 ? 70.0 : (titles.length * 90.0 - 20),
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: titles.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: ButtonPrimaryComponent(
                title: titles[index],
                onPressed: () async {
                  onPresses[index]();
                  Navigator.of(context).pop(true);
                  NotificationDialog.show(
                      context: context, bodyText: notificationTitle);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
