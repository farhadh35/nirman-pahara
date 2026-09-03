import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/app_state.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/content/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

/// A reader is watching a government job or building their own house. "Both"
/// was offered as a third answer and told the app nothing it could act on —
/// picking it simply showed everything — while asking someone in one situation
/// to describe themselves as being in two.
///
/// The value survives as a property of content, because a card about telling
/// good cement from bad genuinely applies either way. It is no longer an
/// answer anyone is asked to give.
void main() {
  test('the picker offers the two real situations, and nothing else', () {
    expect(Track.choices, [Track.government, Track.private]);
    expect(Track.choices, isNot(contains(Track.either)));
  });

  test('the content-only value has no label to show', () {
    // If it ever acquires one, something is about to render it as a choice.
    expect(Track.either.label.bn, isEmpty);
    expect(Track.either.label.en, isEmpty);
    for (final t in Track.choices) {
      expect(t.label.bn.trim(), isNotEmpty);
      expect(t.label.en?.trim() ?? '', isNotEmpty);
    }
  });

  test('someone who had picked "both" is moved to a real answer', () async {
    SharedPreferences.setMockInitialValues({'onboarded': true, 'track': 'both'});
    final state = await AppState.load();
    expect(Track.choices, contains(state.track),
        reason: 'an existing reader is left holding a track the app no longer '
            'offers, and the chips cannot show it as selected');
    expect(state.track, Track.government);
  });

  test('a reader who chose private keeps it', () async {
    SharedPreferences.setMockInitialValues(
        {'onboarded': true, 'track': 'private'});
    final state = await AppState.load();
    expect(state.track, Track.private);
  });

  test('content may still be marked as applying either way', () async {
    // Most of the guide is: how to tell good cement, why curing matters, how
    // to read a drawing. Forcing those into one track would halve the app.
    final guide = await ContentRepository(
            reader: (p) => File(p).readAsString())
        .guide();
    final either =
        guide.modules.where((m) => m.track == Track.either).length;
    expect(either, greaterThan(0),
        reason: 'nothing applies to both situations any more, which would '
            'mean the content was mis-tagged rather than the model fixed');
    for (final t in Track.choices) {
      expect(guide.forTrack(t), isNotEmpty);
    }
  });

  test('parse and parseChoice differ on purpose', () {
    // Content defaults to "applies either way"; a reader defaults to a real
    // situation. Collapsing these was the bug.
    expect(Track.parse(null), Track.either);
    expect(Track.parse('both'), Track.either);
    expect(Track.parseChoice(null), Track.government);
    expect(Track.parseChoice('both'), Track.government);
  });
}
