import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'checklist_models.dart';
import 'models.dart';
import 'rights_models.dart';
import '../../features/prices/logic/price_models.dart';
import '../../features/prices/logic/pwd_rate_table.dart';

/// Loads the bundled content packs.
///
/// Content ships inside the APK so the app is fully usable with no network,
/// which is the normal condition for the audience. The [GuidePack.contentVersion]
/// field is what a future remote-update channel would compare against; nothing
/// else needs to change to add one.
class ContentRepository {
  ContentRepository({AssetBundleReader? reader})
      : _read = reader ?? _defaultReader;

  static Future<String> _defaultReader(String path) =>
      rootBundle.loadString(path);

  final AssetBundleReader _read;

  GuidePack? _guide;
  List<ChecklistPack>? _checklists;
  RightsPack? _rights;
  PricePack? _prices;
  PwdRateTable? _pwdRates;

  Future<void> loadAll() async {
    await Future.wait([guide(), checklists(), rights(), prices()]);
  }

  Future<GuidePack> guide() async {
    if (_guide != null) return _guide!;
    final raw = await _read('assets/content/guide/guide.json');
    _guide = GuidePack.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    return _guide!;
  }

  Future<List<ChecklistPack>> checklists() async {
    if (_checklists != null) return _checklists!;
    final index = jsonDecode(
      await _read('assets/content/checklists/index.json'),
    ) as Map<String, dynamic>;
    final files = (index['packs'] as List).cast<String>();
    final packs = <ChecklistPack>[];
    for (final f in files) {
      final raw = await _read('assets/content/checklists/$f');
      packs.add(
        ChecklistPack.fromJson(jsonDecode(raw) as Map<String, dynamic>),
      );
    }
    _checklists = packs;
    return packs;
  }

  Future<RightsPack> rights() async {
    if (_rights != null) return _rights!;
    final raw = await _read('assets/content/rights.json');
    _rights = RightsPack.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    return _rights!;
  }

  Future<PricePack> prices() async {
    if (_prices != null) return _prices!;
    final raw = await _read('assets/content/rates/prices.json');
    _prices = PricePack.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    return _prices!;
  }

  /// The published PWD rates. Large (about half a megabyte) and only needed on
  /// one screen, so it is deliberately left out of [loadAll].
  Future<PwdRateTable> pwdRates() async {
    if (_pwdRates != null) return _pwdRates!;
    final raw = await _read('assets/content/rates/pwd_sor_2022.json');
    _pwdRates = PwdRateTable.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    return _pwdRates!;
  }

  Future<ChecklistPack?> checklistById(String id) async {
    for (final p in await checklists()) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<List<ChecklistPack>> checklistsForTrack(Track t) async =>
      (await checklists()).where((p) => p.track.covers(t)).toList();
}

typedef AssetBundleReader = Future<String> Function(String path);
