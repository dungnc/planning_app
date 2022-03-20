import 'dart:async';

import 'package:agileplanning/definitions/poker.constants.dart';
import 'package:agileplanning/models/user.model.dart';
import 'package:agileplanning/services/logging.service.dart';
import 'package:agileplanning/services/performance.service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class PokerOfflineSettingsBloc {
  static const _numStartingOptions = 12;
  final _log = LoggingService.withTag((PokerOfflineSettingsBloc).toString());
  final _numOptionsMax = _numStartingOptions;
  final _pokerOptions = List.generate(_numStartingOptions, (_) => '');
  final _pokerOpts = BehaviorSubject.seeded(pokerOptsDefault.toList());
  final _subscriptions = List<StreamSubscription>();

  Stream<PokerUser> get _user => FirebaseAuth.instance
      .authStateChanges()
      .where((firebaseUser) => firebaseUser != null)
      .switchMap((firebaseUser) => FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots())
      .map((doc) => PokerUser.fromFirestore(doc));

  PokerOfflineSettingsBloc() {
    _subscriptions.add(_user
        .map((room) => room?.pokerOptions ?? [])
        .listen((opts) => _pokerOpts.add(opts)));
  }

  void dispose() {
    _log.fine('[dispose]');
    _pokerOpts.close();
    _subscriptions.forEach((subscription) => subscription?.cancel());
  }

  void presetFibonacci() {
    _log.fine('[presetFibonacci]');
    _pokerOpts.add(pokerOptsFibonacci.toList());
  }

  void presetTshirt() {
    _log.fine('[presetTshirt]');
    _pokerOpts.add(pokerOptsTshirt.toList());
  }

  /// Returns a streamed list of 12 poker options
  /// The list is constantly containing 12 elements as the stream will put in
  /// additional empty option values if there are less than 12 in the actual
  /// list.
  Stream<List<String>> get pokerOptions => _pokerOpts.map((options) {
        final numOptsToGenerate = _numOptionsMax - options.length;
        final extraOpts = List.generate(numOptsToGenerate, (_) => '');

        // Extend the options array to ensure minimum length
        options.insertAll(options.length, extraOpts);

        // Update the local copy of poker options
        _pokerOptions.setAll(0, options);

        return options;
      });

  /// Update the poker option at a certain position
  void setPokerOption(int index, String value) {
    _log.fine('[setPokerOption] value: $value, index: $index');
    assert(index < _pokerOptions.length);
    _pokerOptions[index] = value.trim();
  }

  /// Saves the user settings
  Future<void> saveSettings() async {
    _log.fine('[saveSettings]');
    PerformanceService.instance.startTrace('offline_settings_save');
    final firebaseUser = FirebaseAuth.instance.currentUser;
    assert(firebaseUser != null);

    final data = {
      'pokerOptions': _pokerOptions
          .map((opt) => opt.trim())
          .where((opt) => opt.isNotEmpty)
          .toList(),
    };

    FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .update(data);

    return PerformanceService.instance.stopTrace('offline_settings_save');
  }
}
