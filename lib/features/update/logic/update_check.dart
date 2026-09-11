import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Whether a newer version exists, asked in the one way that does not cost the
/// reader anything.
///
/// The store listing promises the app works offline and uploads nothing, and
/// that promise is why a version check is not written by hand here. Play
/// services does the lookup and answers locally; this app opens no socket, and
/// sends no identifier anywhere. With no connection the check fails and the
/// caller is told there is nothing to report — never an error the reader has
/// to dismiss.
///
/// On a sideloaded copy Play has nothing to answer with, so the only honest
/// thing left is to open the store page and let the reader look.
class UpdateCheck {
  const UpdateCheck({this.clock});

  /// Injected so a test does not have to wait a day.
  final DateTime Function()? clock;

  static const storeUrl =
      'https://play.google.com/store/apps/details?id=bd.nirmanpahara.nirman_pahara';

  static const _lastAskedKey = 'update_last_asked';

  /// How long to leave the reader alone after asking once.
  ///
  /// The check runs at startup, and a person who opens this app on site opens
  /// it many times a day. Asking every time would be the app talking about
  /// itself instead of about the building.
  static const quietFor = Duration(days: 1);

  DateTime get _now => (clock ?? DateTime.now)();

  /// True when enough time has passed to look again. Startup calls this first
  /// so the common case costs nothing at all.
  Future<bool> dueForCheck(SharedPreferences prefs) async {
    final last = prefs.getInt(_lastAskedKey);
    if (last == null) return true;
    final since = _now.difference(DateTime.fromMillisecondsSinceEpoch(last));
    return since >= quietFor;
  }

  Future<void> markAsked(SharedPreferences prefs) =>
      prefs.setInt(_lastAskedKey, _now.millisecondsSinceEpoch);

  /// Null when there is nothing to say: no update, no Play, no connection.
  Future<AppUpdateInfo?> available() async {
    if (!_isAndroid) return null;
    try {
      final info = await InAppUpdate.checkForUpdate();
      return info.updateAvailability == UpdateAvailability.updateAvailable
          ? info
          : null;
    } catch (_) {
      // No Play services, no network, a sideloaded build, an emulator without
      // the store. None of these is the reader's problem, and none of them
      // should reach the screen.
      return null;
    }
  }

  /// The gentle flow: the download happens in the background and the reader
  /// keeps using the app. Returns false when Play declines, which is the cue
  /// to fall back to the store page.
  Future<bool> startFlexible() async {
    if (!_isAndroid) return false;
    try {
      await InAppUpdate.startFlexibleUpdate();
      await InAppUpdate.completeFlexibleUpdate();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Opens the listing. Used from settings, and whenever Play cannot help.
  Future<bool> openStore() async {
    try {
      return await launchUrl(Uri.parse(storeUrl),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
}
