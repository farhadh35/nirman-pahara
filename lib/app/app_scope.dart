import 'package:flutter/widgets.dart';

import '../core/content/content_repository.dart';
import '../core/i18n/app_locale.dart';
import '../features/prices/logic/sor_rate_store.dart';
import '../features/inspection/logic/evidence_store.dart';
import '../features/inspection/logic/inspection_store.dart';
import 'app_state.dart';

/// Makes [AppState] and the [ContentRepository] available to the whole tree,
/// and rebuilds on preference changes.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState state,
    required this.content,
    required this.store,
    required this.evidence,
    required this.rates,
    required super.child,
  }) : super(notifier: state);

  final ContentRepository content;
  final InspectionStore store;
  final EvidenceStore evidence;
  final SorRateStore rates;

  static AppScope _of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope above this widget');
    return scope!;
  }

  static AppState stateOf(BuildContext context) => _of(context).notifier!;

  static ContentRepository contentOf(BuildContext context) =>
      _of(context).content;

  static InspectionStore storeOf(BuildContext context) => _of(context).store;

  static EvidenceStore evidenceOf(BuildContext context) =>
      _of(context).evidence;

  static SorRateStore ratesOf(BuildContext context) => _of(context).rates;

  @override
  bool updateShouldNotify(covariant AppScope oldWidget) =>
      super.updateShouldNotify(oldWidget) ||
      oldWidget.content != content ||
      oldWidget.store != store ||
      oldWidget.evidence != evidence ||
      oldWidget.rates != rates;
}

extension AppScopeX on BuildContext {
  AppState get appState => AppScope.stateOf(this);
  ContentRepository get content => AppScope.contentOf(this);
  InspectionStore get inspections => AppScope.storeOf(this);
  EvidenceStore get evidence => AppScope.evidenceOf(this);
  SorRateStore get rates => AppScope.ratesOf(this);
  AppLocale get locale => AppScope.stateOf(this).locale;

  /// Resolves a bilingual string in the current language.
  String t(L10nText text) => text.of(locale);
}
