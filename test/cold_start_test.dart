import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/app_state.dart';
import 'package:nirman_pahara/app/theme.dart';
import 'package:nirman_pahara/core/content/models.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What the app does on the first launch, and on every damaged one.
///
/// AppState is read before the first frame, so anything that throws here does
/// not produce a broken screen — it produces an app that will not start, on
/// every launch, until it is uninstalled. That is the worst failure this app
/// has available to it, and it is the cheapest one to rule out.
void main() {
  test('a first launch picks Bangla, government works, normal text', () async {
    SharedPreferences.setMockInitialValues({});
    final state = await AppState.load();
    expect(state.locale, AppLocale.bn, reason: 'Bangla is the default');
    expect(state.track, Track.government);
    expect(state.textScale, TextScalePreference.normal);
    expect(state.onboarded, isFalse);
  });

  test('a stored choice that no longer exists falls back', () async {
    SharedPreferences.setMockInitialValues({
      'locale': 'fr',
      'track': 'dutoi', // an option that was removed
      'text_scale': 'enormous',
    });
    final state = await AppState.load();
    expect(state.locale, AppLocale.bn);
    expect(state.track, Track.government);
    expect(state.textScale, TextScalePreference.normal);
  });

  test('a preference stored as the wrong type does not stop the app starting',
      () async {
    // SharedPreferences hands back whatever the platform stored and casts it.
    // A key that ever held a different type — an older build, a bad migration,
    // a corrupted file — makes the getter throw, and this runs before the
    // first frame. The app would not open again until it was reinstalled,
    // taking every saved inspection with it.
    SharedPreferences.setMockInitialValues({
      'onboarded': 'true',
      'locale': 1,
      'track': true,
      'text_scale': 3,
    });
    late AppState state;
    expect(() async => state = await AppState.load(), returnsNormally);
    state = await AppState.load();
    expect(state.locale, AppLocale.bn);
    expect(state.track, Track.government);
    expect(state.textScale, TextScalePreference.normal);
    expect(state.onboarded, isFalse);
  });

  test('a choice made once is the choice on the next launch', () async {
    SharedPreferences.setMockInitialValues({});
    final first = await AppState.load();
    first.locale = AppLocale.en;
    first.track = Track.private;
    first.textScale = TextScalePreference.extraLarge;
    first.completeOnboarding();

    final second = await AppState.load();
    expect(second.locale, AppLocale.en);
    expect(second.track, Track.private);
    expect(second.textScale, TextScalePreference.extraLarge);
    expect(second.onboarded, isTrue);
  });
}
