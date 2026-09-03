import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';

import 'photo_ref.dart';

/// Where photographs taken during an inspection are kept.
///
/// Inside the app's own documents directory, not the shared gallery: a
/// half-finished inspection of a neighbour's contract should not scatter
/// photographs through the user's camera roll, and on a shared handset that
/// matters for the photographer's safety as much as for tidiness.
///
/// Files are addressed by name. Android can hand an app a different sandbox
/// path after an update or a restore, so an absolute path stored today may be
/// dead tomorrow; the directory is resolved fresh on every read.
class EvidenceStore {
  EvidenceStore({Future<Directory> Function()? directory})
      : _directory = directory ?? _defaultDirectory;

  static Future<Directory> _defaultDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    return Directory('${base.path}/evidence');
  }

  final Future<Directory> Function() _directory;

  Future<Directory> _ensure() async {
    final dir = await _directory();
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  /// Copies a captured image in and returns a reference carrying when — and,
  /// where the phone can tell us, where — it was taken.
  ///
  /// A missing fix is not an error. The photograph is worth having either way,
  /// and the report says plainly that the location was not recorded rather
  /// than leaving the reader to assume one.
  Future<PhotoRef> addWithContext(
    File source, {
    required String runId,
    required String itemId,
    required DateTime takenAt,
  }) async {
    final name = await add(source, runId: runId, itemId: itemId);
    final fix = await _position();
    return PhotoRef(
      name: name,
      takenAt: takenAt,
      latitude: fix.position?.latitude,
      longitude: fix.position?.longitude,
      outcome: fix.outcome,
    );
  }

  /// Best-effort location. Never throws, never blocks the capture for long,
  /// and reports *why* it failed so the user can act on it.
  Future<({Position? position, LocationOutcome outcome})> _position() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return (position: null, outcome: LocationOutcome.serviceOff);
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return (position: null, outcome: LocationOutcome.permissionDenied);
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          // A person is standing in the sun waiting for a thumbnail. Give up
          // rather than make them wait for a better fix.
          timeLimit: Duration(seconds: 8),
        ),
      );
      return (position: position, outcome: LocationOutcome.recorded);
    } catch (_) {
      // Timed out, or no provider could produce a fix. Caught unconditionally
      // rather than `on Exception`: this method's contract is to return an
      // outcome, and a platform channel that throws an Error instead would
      // otherwise escape into the photo capture and lose the picture along
      // with the location.
      return (position: null, outcome: LocationOutcome.noFix);
    }
  }

  /// Copies a captured image in and returns the name to store on the finding.
  Future<String> add(File source, {required String runId, required String itemId}) async {
    final dir = await _ensure();
    final stamp = source.lastModifiedSync().microsecondsSinceEpoch;
    final name = '${runId}_${itemId}_$stamp${_extension(source.path)}';
    // Synchronous on purpose. These are single small files, and an async
    // file future that has not completed leaves the thumbnail strip showing
    // something that is no longer true.
    source.copySync('${dir.path}/$name');
    return name;
  }

  /// Where generated documents go. Kept apart from the evidence itself so a
  /// rebuilt PDF never looks like another photograph.
  Future<Directory> exportDirectory() async {
    final base = await _directory();
    final dir = Directory('${base.parent.path}/exports');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  Future<File?> file(String name) async {
    final dir = await _ensure();
    final f = File('${dir.path}/$name');
    return f.existsSync() ? f : null;
  }

  Future<void> remove(String name) async {
    (await file(name))?.deleteSync();
  }

  /// Deletes every photograph belonging to a run. Called when a run is
  /// deleted, so removing an inspection does not leave its evidence behind.
  Future<void> removeForRun(String runId) async {
    final dir = await _ensure();
    for (final entity in dir.listSync()) {
      if (entity is File &&
          entity.uri.pathSegments.last.startsWith('${runId}_')) {
        entity.deleteSync();
      }
    }
    // Exported reports too. Deleting an inspection used to leave its PDF on
    // the phone — a document naming the site, the tender and what was seen,
    // still there after the reader had deleted the thing that produced it.
    final exports = await exportDirectory();
    for (final entity in exports.listSync()) {
      if (entity is File &&
          entity.uri.pathSegments.last.contains('_$runId.')) {
        entity.deleteSync();
      }
    }
  }

  static String _extension(String path) {
    final dot = path.lastIndexOf('.');
    return dot == -1 ? '.jpg' : path.substring(dot).toLowerCase();
  }
}
