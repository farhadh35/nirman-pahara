import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A rate the user copied out of a published schedule.
class SavedRate {
  const SavedRate({required this.rateBdt, this.itemNo, this.asOf});

  final double rateBdt;
  final String? itemNo;

  /// Which revision or date the user read it from, in their own words.
  final String? asOf;

  Map<String, dynamic> toJson() => {
        'rate': rateBdt,
        if (itemNo != null && itemNo!.isNotEmpty) 'item_no': itemNo,
        if (asOf != null && asOf!.isNotEmpty) 'as_of': asOf,
      };

  static SavedRate fromJson(Map<String, dynamic> j) => SavedRate(
        rateBdt: (j['rate'] as num).toDouble(),
        itemNo: j['item_no'] as String?,
        asOf: j['as_of'] as String?,
      );
}

/// Remembers the schedule rates a user has typed in.
///
/// Rates are not shipped with the app — see [SorItem]. But a person who has
/// looked one up once should never have to look it up again, and over a season
/// a UP member or a citizen monitor accumulates the rate book for the works
/// they actually watch.
class SorRateStore extends ChangeNotifier {
  SorRateStore(this._prefs);

  static const _key = 'sor_rates';

  final SharedPreferences _prefs;

  Map<String, SavedRate> all() {
    final stored = _prefs.get(_key);
    final raw = stored is String ? stored : null;
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = (jsonDecode(raw) as Map).cast<String, dynamic>();
      return {
        for (final e in decoded.entries)
          e.key: SavedRate.fromJson((e.value as Map).cast<String, dynamic>()),
      };
    } catch (_) {
      // Everything, not just Exception: text that is not JSON raises a
      // FormatException, but valid JSON of the wrong shape raises a TypeError,
      // which `on Exception` does not catch. These are rates the reader typed
      // in to compare against a bill — worth starting again from empty, never
      // worth throwing out of a getter that the prices screen calls to build.
      return {};
    }
  }

  SavedRate? forItem(String itemId) => all()[itemId];

  Future<void> save(String itemId, SavedRate rate) async {
    final next = all()..[itemId] = rate;
    await _write(next);
  }

  Future<void> clear(String itemId) async {
    final next = all()..remove(itemId);
    await _write(next);
  }

  Future<void> _write(Map<String, SavedRate> rates) async {
    await _prefs.setString(
      _key,
      jsonEncode({for (final e in rates.entries) e.key: e.value.toJson()}),
    );
    notifyListeners();
  }
}
