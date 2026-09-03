import '../i18n/app_locale.dart';
import 'models.dart';

/// One rung of the complaint ladder.
///
/// The order matters. A complaint fired at the top usually comes back down,
/// and confronting a contractor alone on site can be unsafe. The app walks the
/// ladder from the bottom up.
/// A fill-in-the-blanks letter: an RTI application, a written complaint.
class LetterTemplate {
  const LetterTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.fields,
    required this.body,
    this.track = Track.either,
    this.footnote,
  });

  final String id;
  final Track track;
  final L10nText title;
  final L10nText description;

  /// Placeholders the user fills, in display order.
  final List<LetterField> fields;

  /// Template text; each field appears as {{key}}.
  final L10nText body;

  final L10nText? footnote;

  factory LetterTemplate.fromJson(Map<String, dynamic> j) => LetterTemplate(
        id: j['id'] as String,
        title: L10nText.fromJson(j['title']),
        description: L10nText.fromJson(j['description']),
        body: L10nText.fromJson(j['body']),
        track: Track.parse(j['track'] as String?),
        footnote:
            j['footnote'] == null ? null : L10nText.fromJson(j['footnote']),
        fields: (j['fields'] as List)
            .map((e) => LetterField.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Substitutes [values] into the template.
  ///
  /// A missing value is left as the field's own label in brackets rather than a
  /// row of underscores. In the signature block an anonymous blank line reads
  /// as somewhere to sign; "[আপনার নাম]" tells the user what is still missing
  /// and keeps a half-filled letter obviously half-filled.
  String render(Map<String, String> values, AppLocale locale) {
    var out = body.of(locale);
    for (final f in fields) {
      final v = values[f.key];
      out = out.replaceAll(
        '{{${f.key}}}',
        v == null || v.trim().isEmpty ? '[${f.label.of(locale)}]' : v.trim(),
      );
    }
    return out;
  }
}

class LetterField {
  const LetterField({
    required this.key,
    required this.label,
    this.hint,
    this.multiline = false,
    this.keyboard = LetterKeyboard.text,
  });

  final String key;
  final L10nText label;
  final L10nText? hint;
  final bool multiline;

  /// Which keyboard to raise. A mobile number typed on a full alphabetic
  /// keyboard is a small, avoidable tax on every user.
  final LetterKeyboard keyboard;

  factory LetterField.fromJson(Map<String, dynamic> j) => LetterField(
        key: j['key'] as String,
        label: L10nText.fromJson(j['label']),
        hint: j['hint'] == null ? null : L10nText.fromJson(j['hint']),
        multiline: j['multiline'] as bool? ?? false,
        keyboard: LetterKeyboard.parse(j['keyboard'] as String?),
      );
}

enum LetterKeyboard {
  text,
  phone,
  number;

  static LetterKeyboard parse(String? s) => switch (s) {
        'phone' => LetterKeyboard.phone,
        'number' => LetterKeyboard.number,
        _ => LetterKeyboard.text,
      };
}

class RightsPack {
  const RightsPack({
    required this.contentVersion,
    required this.updated,
    required this.letters,
  });

  final int contentVersion;
  final String updated;
  final List<LetterTemplate> letters;

  factory RightsPack.fromJson(Map<String, dynamic> j) => RightsPack(
        contentVersion: j['content_version'] as int,
        updated: j['updated'] as String,
        letters: (j['letters'] as List)
            .map((e) => LetterTemplate.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  LetterTemplate? letterById(String id) {
    for (final l in letters) {
      if (l.id == id) return l;
    }
    return null;
  }

  List<LetterTemplate> lettersFor(Track t) =>
      letters.where((l) => l.track.covers(t)).toList();
}
