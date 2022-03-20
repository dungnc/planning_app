import 'package:agileplanning/app_info.dart';
import 'package:agileplanning/blocs/user.bloc.dart';
import 'package:agileplanning/components/scaffolds/scaffold_plain.component.dart';
import 'package:agileplanning/definitions/language.constants.dart';
import 'package:agileplanning/definitions/theme.dart';
import 'package:agileplanning/l10n/app_localizations.dart';
import 'package:agileplanning/l10n/localizations_delegate.dart';
import 'package:agileplanning/navigation/navigation.dart';
import 'package:agileplanning/screens/onboarding/onboarding.screen.dart';
import 'package:agileplanning/screens/poker_offline/poker_offline.screen.dart';
import 'package:agileplanning/screens/splash/splash.screen.dart';
import 'package:agileplanning/services/firebase_messaging.service.dart';
import 'package:agileplanning/services/logging.service.dart';
import 'package:agileplanning/services/remote_config.service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final _log = LoggingService.withTag((_MyAppState).toString());
  final userBloc = UserBloc();
  static FirebaseInAppMessaging fiam = FirebaseInAppMessaging();

  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      fiam.setAutomaticDataCollectionEnabled(false);

      // We mush running Firebase.initializeApp() for fist time
      LoggingService.initialize();
      _log.fine('[initState]');

      await RemoteConfigService.instance.initialize();
      AppLocalizations.setUserLanguage(defaultLanguage);
      userBloc.goOnline();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    initializeFlutterFire();
  }

  @override
  void dispose() {
    _log.fine('[dispose]');
    userBloc.goOffline();

    // UserBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    if (_error) {
      return MaterialApp(
          theme: theme,
          home: ScaffoldPlain(
              body: Center(
            child: Text('Something when wrong'),
          )));
    }

    // Show a loader until FlutterFire is initialized
    // if (!_initialized) {
    //   return MaterialApp(
    //     theme: theme,
    //     home: SplashScreen(),
    //   );
    // }
    return MaterialApp(
      title: AppInfo.title,
      theme: theme,
      home: _initialized ? _AuthStateProxyScreen() : SplashScreen(),
      onGenerateRoute: AppNavigation.handleRoute,
      supportedLocales: supportedLanguages.map((s) => Locale(s)),
      localizationsDelegates: [
        AppLocalizationsDelegate(),
      ],
    );
  }
}

class _AuthStateProxyScreen extends StatelessWidget {
  final userBloc = UserBloc();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: userBloc.isOnboarded,
      initialData: null,
      builder: (context, snap) {
        final isOnboarded = snap.data;
        if (isOnboarded == null) {
          return SplashScreen();
        } else if (isOnboarded) {
          return PokerOfflineScreen();
        } else {
          return OnboardingScreen();
        }
      },
    );
  }
}
