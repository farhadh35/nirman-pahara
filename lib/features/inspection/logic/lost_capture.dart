import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Recovers a photograph Android took but never handed back.
///
/// When the camera opens, the system camera app comes to the front and this app
/// goes to the back — and on a handset short of memory Android is entitled to
/// kill a backgrounded process. The picture is taken and saved; the app that
/// asked for it is gone by the time it is offered. `pickImage` never returns,
/// and nothing on the ordinary path knows a photograph is waiting.
///
/// This is not a rare case for the people this app is for. It is a cheap phone,
/// on a site, with the camera open. And the cost is not a lost tap: it is a
/// photograph of something that has since been covered over.
///
/// So the item being photographed is written down before the camera opens, and
/// when that inspection is next opened the platform is asked whether it is
/// holding anything. Nothing is recovered without that note, so a photograph
/// can never be attached to the wrong item.
class LostCapture {
  LostCapture({
    Future<LostDataResponse> Function()? retrieve,
    bool? supported,
  })  : _retrieve = retrieve ?? (() => ImagePicker().retrieveLostData()),
        // Only Android drops a result this way; asking elsewhere throws.
        _supported = supported ?? Platform.isAndroid;

  final Future<LostDataResponse> Function() _retrieve;
  final bool _supported;

  static const _key = 'pending_capture';
  static const _sep = ' ';

  /// Note which item the camera is being opened for.
  Future<void> awaiting({required String runId, required String itemId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, '$runId$_sep$itemId');
  }

  /// The camera came back the ordinary way; there is nothing to recover.
  Future<void> settled() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// A photograph the platform kept for [runId], if there is one.
  ///
  /// Returns null in every ordinary case, including when the platform has an
  /// image but no note says which item it belongs to — an orphan photograph
  /// filed against a guess would be worse than none.
  Future<({String itemId, File file})?> recover(String runId) async {
    if (!_supported) return null;
    final prefs = await SharedPreferences.getInstance();
    final note = prefs.getString(_key);
    if (note == null) return null;

    final parts = note.split(_sep);
    if (parts.length != 2 || parts.first != runId) return null;

    final LostDataResponse response;
    try {
      response = await _retrieve();
    } catch (_) {
      // A platform that cannot answer is the same as one holding nothing.
      return null;
    }

    final file = response.file;
    if (file == null) return null;
    await prefs.remove(_key);
    return (itemId: parts[1], file: File(file.path));
  }
}
