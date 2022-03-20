import 'package:agileplanning/components/scaffolds/scaffold_plain.component.dart';
import 'package:agileplanning/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class RouteNotFoundScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScaffoldPlain(
      body: Center(
        child: Text(
          l10n.errorRouteNotImplemented,
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
    );
  }
}
