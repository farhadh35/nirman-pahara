import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/content/models.dart';
import '../core/i18n/app_locale.dart';
import 'theme.dart';

/// User preferences that change what the whole app shows.
///
/// Deliberately tiny and synchronous to read: the app has to start and be
/// usable on a slow phone with no network, so nothing here waits on anything.
class AppState extends ChangeNotifier {
  AppState._(this._prefs)
      : _locale = AppLocale.parse(_prefs.getString(_kLocale)),
        _track = Track.parse(_prefs.getString(_kTrack)),
        _textScale = TextScalePreference.values.firstWhere(
          (t) => t.name == _prefs.getString(_kTextScale),
          orElse: () => TextScalePreference.normal,
        ),
        _onboarded = _prefs.getBool(_kOnboarded) ?? false;

  static const _kLocale = 'locale';
  static const _kTrack = 'track';
  static const _kTextScale = 'text_scale';
  static const _kOnboarded = 'onboarded';

  final SharedPreferences _prefs;

  AppLocale _locale;
  Track _track;
  TextScalePreference _textScale;
  bool _onboarded;

  static Future<AppState> load() async =>
      AppState._(await SharedPreferences.getInstance());

  /// Bangla is the default; English is opt-in.
  AppLocale get locale => _locale;
  Track get track => _track;
  TextScalePreference get textScale => _textScale;
  bool get onboarded => _onboarded;

  set locale(AppLocale v) {
    if (v == _locale) return;
    _locale = v;
    _prefs.setString(_kLocale, v.code);
    notifyListeners();
  }

  set track(Track v) {
    if (v == _track) return;
    _track = v;
    _prefs.setString(_kTrack, v.name);
    notifyListeners();
  }

  set textScale(TextScalePreference v) {
    if (v == _textScale) return;
    _textScale = v;
    _prefs.setString(_kTextScale, v.name);
    notifyListeners();
  }

  void completeOnboarding() {
    if (_onboarded) return;
    _onboarded = true;
    _prefs.setBool(_kOnboarded, true);
    notifyListeners();
  }
}
