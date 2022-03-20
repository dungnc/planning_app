import 'package:agileplanning/components/buttons/button_dismiss.component.dart';
import 'package:agileplanning/components/buttons/button_primary.component.dart';
import 'package:agileplanning/components/buttons/button_secondary.component.dart';
import 'package:agileplanning/definitions/theme_colors.constants.dart';
import 'package:agileplanning/definitions/theme_text_styles.constants.dart';
import 'package:agileplanning/l10n/app_localizations.dart';
import 'package:agileplanning/screens/poker_offline_settings/poker_offline_settings.bloc.dart';
import 'package:agileplanning/services/analytics.service.dart';
import 'package:agileplanning/services/logging.service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PokerOfflineSettingsDialog extends StatefulWidget {
  static show(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => PokerOfflineSettingsDialog(),
    );
  }

  @override
  _PokerOfflineSettingsDialogState createState() =>
      _PokerOfflineSettingsDialogState();
}

class _PokerOfflineSettingsDialogState
    extends State<PokerOfflineSettingsDialog> {
  static final _log =
      LoggingService.withTag((_PokerOfflineSettingsDialogState).toString());

  PokerOfflineSettingsBloc _settingsBloc;

  @override
  void initState() {
    super.initState();
    _log.finer('[initState]');
    _settingsBloc = PokerOfflineSettingsBloc();
  }

  @override
  void dispose() {
    _log.finer('[dispose]');
    _settingsBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: ThemeColors.appBackgroundSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        width: kIsWeb ? 420 : MediaQuery.of(context).size.width,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: ButtonDismissComponent(
                size: 20.0,
                onPressed: _onDismissButtonPressed,
              ),
            ),
            StreamBuilder<List<String>>(
              stream: _settingsBloc.pokerOptions,
              initialData: [],
              builder: (_, snap) => GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 1.5,
                crossAxisSpacing: 20.0,
                mainAxisSpacing: 20.0,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 24.0),
                children: snap.data
                    .asMap()
                    .keys
                    .map((index) => _pokerOption(index, snap.data[index]))
                    .toList(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ButtonSecondaryComponent(
                  title: l10n.ctaPresetFibonacci,
                  small: true,
                  onPressed: _onFibonacciPresetPressed,
                ),
                ButtonSecondaryComponent(
                  title: l10n.ctaPresetTshirt,
                  small: true,
                  onPressed: _onTshirtPresetPressed,
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 24.0,
                bottom: 16.0,
              ),
              child: ButtonPrimaryComponent(
                title: l10n.ctaSave,
                onPressed: () => _onSettingsSavedPressed(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pokerOption(int index, String option) {
    _log.finest('[_pokerOption] $index: $option');
    final controller = TextEditingController();
    controller.text = option;
    return TextFormField(
      controller: controller,
      // initialValue: option,
      textAlign: TextAlign.center,
      textAlignVertical: TextAlignVertical.center,
      textCapitalization: TextCapitalization.none,
      keyboardType: TextInputType.visiblePassword,
      maxLength: 3,
      maxLines: 1,
      style: ThemeTextStyles.pokerOption.copyWith(
        fontSize: 22.0,
        color: Colors.white,
      ),
      onChanged: (value) => _settingsBloc.setPokerOption(index, value),
      decoration: InputDecoration(
        errorMaxLines: 4,
        counterText: '', // Removes the character count under widget
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          gapPadding: 0.0,
          borderSide: BorderSide(
            style: BorderStyle.solid,
            color: ThemeColors.secondary,
            width: 1.0,
          ),
        ),
      ),
    );
  }

  void _onFibonacciPresetPressed() {
    AnalyticsService.logButtonClick('online_preset_fibonacci');
    _settingsBloc.presetFibonacci();
  }

  void _onTshirtPresetPressed() {
    AnalyticsService.logButtonClick('online_preset_tshirt');
    _settingsBloc.presetTshirt();
  }

  Future<void> _onSettingsSavedPressed(BuildContext context) async {
    AnalyticsService.logButtonClick('offline_settings_save');
    _settingsBloc.saveSettings();
    return Navigator.of(context).pop();
  }

  void _onDismissButtonPressed() {
    AnalyticsService.logButtonClick('offline_settings_dismiss');
    Navigator.of(context).pop();
  }
}
