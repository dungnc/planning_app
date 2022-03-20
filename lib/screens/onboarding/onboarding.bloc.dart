import 'package:agileplanning/models/user.model.dart';
import 'package:agileplanning/services/analytics.service.dart';
import 'package:agileplanning/services/logging.service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class OnboardingBloc {
  static final _logger = LoggingService.withTag((OnboardingBloc).toString());
  static const minLengthName = 3;
  static const maxLengthName = 25;

  final avatars = List<String>.generate(25, (i) => (i + 1).toString());
  String selectedName;
  String _selectedAvatar;

  OnboardingBloc();

  Stream<PokerUser> get _user => FirebaseAuth.instance
      .authStateChanges()
      .where((firebaseUser) => firebaseUser != null)
      .switchMap((firebaseUser) => FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots())
      .map((doc) => doc.exists ? PokerUser.fromFirestore(doc) : null);

  Stream<String> get userAvatar => _user.map((user) => user.avatar);

  String get selectedAvatar => _selectedAvatar;

  bool get hasSelectedAvatar => _selectedAvatar?.isNotEmpty == true;

  bool isSelectedAvatar(String avatar) => _selectedAvatar == avatar;

  Stream<String> get userName => _user.map((user) => user.name);

  bool get hasValidName => selectedName != null;

  touchUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    assert(firebaseUser != null);
    final user = PokerUser(id: firebaseUser.uid);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .set(user.toJson(stripEmpty: true), SetOptions(merge: true));
  }

  saveName() async {
    _logger.finer('[saveName] $selectedName');
    final user = await _user.first;
    assert(user != null);

    user.name = selectedName;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .set(user.toJson());
  }

  set selectedAvatar(String avatar) {
    _logger.finer('[selectedAvatar] $avatar');
    AnalyticsService.logConsiderAvatar(avatar);
    _selectedAvatar = avatar;
  }

  saveAvatar() async {
    _logger.finer('[saveAvatar] $_selectedAvatar');
    final user = await _user.first;
    assert(user != null);

    AnalyticsService.logSelectAvatar(_selectedAvatar);
    user.avatar = _selectedAvatar;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .set(user.toJson());
  }
}
