import '../../../core/i18n/app_locale.dart';
import '../../../core/util/bn.dart';

/// A photograph, with the context that makes it evidence rather than a picture.
///
/// A slab that is dry is only worth reporting if it is known *when* it was seen
/// dry, and a road is only identifiable if it is known *where*. Both are
/// recorded at capture, and both are allowed to be missing: a phone with the
/// location permission refused, or no fix under a tin roof, must still be able
/// to take the photograph. What the app must never do is imply it knows a
/// location it does not have.
/// Why a photograph has no coordinates.
///
/// "Location not recorded" is honest but useless on its own: each cause needs a
/// different action from the user, and only they can take it.
enum LocationOutcome {
  recorded,
  serviceOff,
  permissionDenied,
  noFix,

  /// A photograph saved before the app recorded a reason. Saying only that the
  /// location is missing is all that can honestly be said about it.
  unknown;

  static LocationOutcome parse(String? s) => switch (s) {
        'service_off' => LocationOutcome.serviceOff,
        'permission_denied' => LocationOutcome.permissionDenied,
        'no_fix' => LocationOutcome.noFix,
        'recorded' => LocationOutcome.recorded,
        _ => LocationOutcome.unknown,
      };

  String get key => switch (this) {
        LocationOutcome.recorded => 'recorded',
        LocationOutcome.serviceOff => 'service_off',
        LocationOutcome.permissionDenied => 'permission_denied',
        LocationOutcome.noFix => 'no_fix',
        LocationOutcome.unknown => 'unknown',
      };

  /// What the user would read, and what they can do about it.
  L10nText get explanation => switch (this) {
        LocationOutcome.recorded => const L10nText('', ''),
        LocationOutcome.serviceOff => const L10nText(
            'অবস্থান রেকর্ড হয়নি — ফোনের লোকেশন বন্ধ ছিল',
            'location not recorded — the phone\'s location was switched off',
          ),
        LocationOutcome.permissionDenied => const L10nText(
            'অবস্থান রেকর্ড হয়নি — অ্যাপকে অনুমতি দেওয়া হয়নি',
            'location not recorded — the app was not given permission',
          ),
        LocationOutcome.noFix => const L10nText(
            'অবস্থান রেকর্ড হয়নি — জিপিএস সিগন্যাল পাওয়া যায়নি',
            'location not recorded — no GPS signal',
          ),
        LocationOutcome.unknown => const L10nText(
            'অবস্থান রেকর্ড হয়নি',
            'location not recorded',
          ),
      };
}

class PhotoRef {
  const PhotoRef({
    required this.name,
    required this.takenAt,
    this.latitude,
    this.longitude,
    this.outcome = LocationOutcome.unknown,
  });

  /// File name inside the evidence directory.
  final String name;

  final DateTime takenAt;

  final double? latitude;
  final double? longitude;

  /// Why the coordinates are missing, when they are.
  final LocationOutcome outcome;

  bool get hasLocation => latitude != null && longitude != null;

  /// Accepts both the object form and the bare file name written by earlier
  /// versions, so photographs taken before this existed are not orphaned.
  static PhotoRef fromJson(dynamic j, {required DateTime fallbackTakenAt}) {
    if (j is String) {
      return PhotoRef(name: j, takenAt: fallbackTakenAt);
    }
    final m = (j as Map).cast<String, dynamic>();
    return PhotoRef(
      name: m['name'] as String,
      takenAt: m['taken_at'] == null
          ? fallbackTakenAt
          : DateTime.parse(m['taken_at'] as String),
      latitude: (m['lat'] as num?)?.toDouble(),
      longitude: (m['lon'] as num?)?.toDouble(),
      outcome: LocationOutcome.parse(m['location_outcome'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'taken_at': takenAt.toIso8601String(),
        if (latitude != null) 'lat': latitude,
        if (longitude != null) 'lon': longitude,
        if (!hasLocation) 'location_outcome': outcome.key,
      };

  /// "১২ জুলাই ২০২৬, ০৯:৩০ · ২৪.৮৯৪৩, ৮৯.৩৭২১"
  String describe(AppLocale locale) {
    String two(int v) => v.toString().padLeft(2, '0');
    final when = Bn.localiseDigits(
      '${takenAt.year}-${two(takenAt.month)}-${two(takenAt.day)} '
      '${two(takenAt.hour)}:${two(takenAt.minute)}',
      locale,
    );
    if (!hasLocation) {
      final why = outcome.explanation.of(locale);
      // Never leave a dangling separator with nothing after it.
      return why.isEmpty ? when : '$when · $why';
    }
    // Left in western digits whatever the language. A coordinate exists to be
    // put into a map, and no mapping tool accepts "২৪.৮৯৪৩১, ৮৯.৩৭২১৫". The
    // time beside it is read rather than re-entered, so that stays Bangla.
    final where =
        '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}';
    return '$when · $where';
  }

  @override
  bool operator ==(Object other) =>
      other is PhotoRef &&
      other.name == name &&
      other.takenAt == takenAt &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(name, takenAt, latitude, longitude);
}
