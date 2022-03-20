import 'package:agileplanning/components/buttons/button_primary.component.dart';
import 'package:agileplanning/components/buttons/button_secondary.component.dart';
import 'package:agileplanning/definitions/theme_colors.constants.dart';
import 'package:agileplanning/extensions/string.extension.dart';
import 'package:agileplanning/services/analytics.service.dart';
import 'package:agileplanning/services/logging.service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  static final _log = LoggingService.withTag((ConfirmationDialog).toString());

  final String id;
  final String bodyText;
  final String titleButtonAccept;
  final String titleButtonDecline;

  const ConfirmationDialog({
    Key key,
    @required this.id,
    @required this.bodyText,
    @required this.titleButtonAccept,
    this.titleButtonDecline,
  }) : super(key: key);

  static show({
    @required BuildContext context,
    @required String id,
    @required String bodyText,
    @required String titleButtonAccept,
    String titleButtonDecline,
  }) async {
    final confirmed = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ConfirmationDialog(
        id: id,
        bodyText: bodyText,
        titleButtonAccept: titleButtonAccept,
        titleButtonDecline: titleButtonDecline,
      ),
    );

    return confirmed == true || titleButtonDecline == null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AlertDialog(
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
              child: Wrap(
                runSpacing: 20.0,
                children: [
                  Text(
                    bodyText.changeCasing(StringCasing.UpperCase),
                    style: Theme.of(context).textTheme.bodyText1,
                    textAlign: TextAlign.center,
                  ),
                  ButtonPrimaryComponent(
                    title: titleButtonAccept,
                    onPressed: () async {
                      _log.fine('Accept');
                      AnalyticsService.logButtonClick('dialog_${id}_accept');
                      Navigator.of(context).pop(true);
                    },
                  ),
                  if (titleButtonDecline != null)
                    ButtonSecondaryComponent(
                      title: titleButtonDecline,
                      onPressed: () {
                        _log.fine('Decline');
                        AnalyticsService.logButtonClick('dialog_${id}_decline');
                        Navigator.of(context).pop(false);
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
