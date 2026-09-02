import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/app_state.dart';
import 'core/content/content_repository.dart';
import 'features/inspection/logic/evidence_store.dart';
import 'features/prices/logic/sor_rate_store.dart';
import 'features/inspection/logic/inspection_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(NirmanPaharaApp(
    state: await AppState.load(),
    content: ContentRepository(),
    store: PrefsInspectionStore(prefs),
    evidence: EvidenceStore(),
    rates: SorRateStore(prefs),
  ));
}
