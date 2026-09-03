import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/content/checklist_models.dart';
import 'inspection_run.dart';

/// Where inspections live between visits.
///
/// Without this the app quietly threw away work: walk half a road, step into
/// the guide to check what cover blocks are, come back, and every answer was
/// gone. Worse for the checks that matter most — watching a slab get watered
/// over several days needs the same run reopened tomorrow.
///
/// Backed by SharedPreferences because the payload is small (answers and short
/// notes, no photographs yet) and it adds no dependency. When photo evidence
/// lands, the blobs go to the filesystem and only their paths come in here;
/// nothing in the UI has to change.
/// A [ChangeNotifier] so that any screen showing the list refreshes itself
/// when a run is saved or deleted anywhere. Threading a callback back up
/// through the navigation stack worked only as long as every await in the
/// chain stayed correct, which is a fragile thing to rely on for the user's
/// saved work.
abstract class InspectionStore extends ChangeNotifier {
  Future<List<InspectionRun>> load(List<ChecklistPack> packs);
  Future<void> save(InspectionRun run);
  Future<void> delete(String id);
}

class PrefsInspectionStore extends InspectionStore {
  PrefsInspectionStore(this._prefs, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  static const _key = 'inspection_runs';

  final SharedPreferences _prefs;

  /// Injectable so tests can assert on ordering without sleeping.
  final DateTime Function() _now;

  /// The saved entries, without trusting what is under the key.
  ///
  /// getStringList casts, so a key holding anything else throws — and it is
  /// read by save and delete as well as load, which would mean the reader
  /// could neither see their inspections nor record a new one.
  List<String> _stored() {
    final value = _prefs.get(_key);
    return value is List<String> ? value : const [];
  }

  @override
  Future<List<InspectionRun>> load(List<ChecklistPack> packs) async {
    final raw = _stored();
    final runs = <InspectionRun>[];
    for (final entry in raw) {
      try {
        final run = InspectionRun.fromJson(
          jsonDecode(entry) as Map<String, dynamic>,
          packs,
        );
        if (run != null) runs.add(run);
      } catch (_) {
        // Deliberately catching everything, not just Exception. Text that is
        // not JSON raises a FormatException, but valid JSON of the wrong shape
        // raises a TypeError — an Error, which `on Exception` does not catch —
        // and one entry written by a different schema would then throw out of
        // load() and take every inspection with it. This list is the reader's
        // record of walks they have already made; no single bad row in it is
        // worth losing the rest.
        continue;
      }
    }
    // Most recently worked on first — that is the one being continued.
    runs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return runs;
  }

  @override
  Future<void> save(InspectionRun run) async {
    run.updatedAt = _now();
    final raw = List<String>.from(_stored());
    raw.removeWhere((e) => _idOf(e) == run.id);
    raw.add(jsonEncode(run.toJson()));
    await _prefs.setStringList(_key, raw);
    notifyListeners();
  }

  @override
  Future<void> delete(String id) async {
    final raw = List<String>.from(_stored());
    raw.removeWhere((e) => _idOf(e) == id);
    await _prefs.setStringList(_key, raw);
    notifyListeners();
  }

  static String? _idOf(String entry) {
    try {
      return (jsonDecode(entry) as Map<String, dynamic>)['id'] as String?;
    } on FormatException {
      return null;
    }
  }
}
