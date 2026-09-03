import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_scope.dart';
import '../../../core/i18n/app_locale.dart';
import '../../../app/widgets/common.dart';
import '../../../app/widgets/locale_fields.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/util/bn.dart';
import '../../../core/util/grouped_number_formatter.dart';
import '../../calculators/logic/calc_result.dart';
import '../logic/country_benchmark_calculator.dart';
import '../logic/market_price_calculator.dart';
import '../logic/price_models.dart';
import '../logic/pwd_rate_table.dart';
import 'boq_tab.dart';

/// Formats a dollar figure, or a range of them, in millions.
///
/// "M" reads as nothing in Bangla, so the Bangla side spells the unit out. The
/// currency symbol and the unit each appear once, however many numbers are
/// between them: "$১.১–১.৩ মিলিয়ন", not "$১.১–$১.৩ মিলিয়ন".
String _usdMillions(
  double usd,
  AppLocale locale, {
  double? to,
  int decimals = 1,
}) {
  String n(double v) => Bn.number(v / 1e6, decimals: decimals, locale: locale);
  final body = to == null ? n(usd) : '${n(usd)}–${n(to)}';
  return locale.isBangla ? '\$$body মিলিয়ন' : '\$${body}M';
}

/// Two ways of asking "is this price reasonable": against the local market
/// band, and against what the same thing costs in other countries.
class PricesScreen extends StatelessWidget {
  const PricesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bn = context.locale.isBangla;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.t(S.prices)),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: context.t(S.marketPrice)),
              Tab(text: bn ? 'BoQ যাচাই' : 'Check a BoQ rate'),
              Tab(text: context.t(S.countryCompare)),
            ],
          ),
        ),
        body: ContentBuilder<({PricePack prices, List<PwdRateTable> rates})>(
          future: _load(context),
          builder: (context, data) => TabBarView(
            children: [
              _MarketTab(pack: data.prices),
              BoqTab(tables: data.rates),
              _CountryTab(pack: data.prices),
            ],
          ),
        ),
      ),
    );
  }

  Future<({PricePack prices, List<PwdRateTable> rates})> _load(
      BuildContext context) async {
    final content = context.content;
    return (
      prices: await content.prices(),
      rates: [await content.pwdRates(), await content.pwdEmRates()],
    );
  }
}

class _MarketTab extends StatefulWidget {
  const _MarketTab({required this.pack});

  final PricePack pack;

  @override
  State<_MarketTab> createState() => _MarketTabState();
}

class _MarketTabState extends State<_MarketTab> {
  late MaterialPrice _material = widget.pack.materials.first;
  final _quote = TextEditingController();
  final _quantity = TextEditingController();
  bool _seeded = false;
  AppLocale? _seededLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = context.locale;
    if (!_seeded) {
      _seeded = true;
      _quantity.text = Bn.localiseDigits('1', locale);
    } else if (_seededLocale != locale) {
      followLocaleDigits([_quote, _quantity], locale);
    }
    _seededLocale = locale;
  }

  @override
  void dispose() {
    _quote.dispose();
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final theme = Theme.of(context);
    final quoted = Bn.parse(_quote.text) ?? 0;
    final quantity = Bn.parse(_quantity.text) ?? 1;

    CalcResult? result;
    if (quoted > 0 && quantity > 0) {
      try {
        result = const MarketPriceCalculator()
            .compare(market: _material, quotedBdt: quoted, quantity: quantity);
      } on CalcException {
        result = null;
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        CautionBox(text: context.t(S.pricesMove), icon: Icons.schedule),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _material.id,
          isExpanded: true,
          decoration: InputDecoration(labelText: context.t(S.marketPrice)),
          items: [
            for (final m in widget.pack.materials)
              DropdownMenuItem(
                value: m.id,
                child: Text('${m.name.of(locale)} · ${m.unit.of(locale)}'),
              )
          ],
          onChanged: (v) => setState(
            () => _material = widget.pack.materialById(v!)!,
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: context.t(S.marketPrice),
          icon: Icons.storefront_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueRow(
                label: _material.unit.of(locale),
                value: '${Bn.taka(_material.lowBdt, locale: locale)} – '
                    '${Bn.number(_material.highBdt, decimals: 0, locale: locale)}',
                emphasis: true,
              ),
              ValueRow(
                label: context.t(S.asOf),
                value: Bn.localiseDigits(_material.asOf, locale),
              ),
              if (_material.note != null) ...[
                const SizedBox(height: 8),
                Text(_material.note!.of(locale),
                    style: theme.textTheme.bodySmall),
              ],
              ReviewBadge(status: _material.status),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _quote,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9০-৯.,\s]')),
            GroupedNumberFormatter(locale),
          ],
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: context.t(S.yourQuote),
            suffixText: locale.isBangla ? '৳' : 'Tk',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _quantity,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9০-৯.,\s]')),
          ],
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: locale.isBangla ? 'পরিমাণ' : 'Quantity',
            suffixText: _material.unit.of(locale),
          ),
        ),
        const SizedBox(height: 20),
        if (result != null) _PriceResult(result: result),
      ],
    );
  }
}

class _PriceResult extends StatelessWidget {
  const _PriceResult({required this.result});

  final CalcResult result;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: context.t(S.result),
          icon: Icons.balance_outlined,
          child: Column(
            children: [
              for (final l in result.lines)
                ValueRow(
                  label: l.label.of(locale),
                  value: l.key == 'vs_mid_percent'
                      ? '${Bn.number(l.value, decimals: 1, locale: locale)}%'
                      : Bn.taka(l.value, locale: locale),
                  emphasis: l.emphasis,
                ),
            ],
          ),
        ),
        if (result.note != null) ...[
          const SizedBox(height: 12),
          CautionBox(text: result.note!.of(locale), icon: Icons.info_outline),
        ],
      ],
    );
  }
}

class _CountryTab extends StatefulWidget {
  const _CountryTab({required this.pack});

  final PricePack pack;

  @override
  State<_CountryTab> createState() => _CountryTabState();
}

class _CountryTabState extends State<_CountryTab> {
  late BenchmarkItem _item = widget.pack.items.first;
  final _fx = TextEditingController();
  final _cost = TextEditingController();
  final _quantity = TextEditingController();
  bool _seeded = false;
  AppLocale? _seededLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = context.locale;
    if (!_seeded) {
      _seeded = true;
      _fx.text =
          Bn.localiseDigits(widget.pack.seedUsdToBdt.toString(), locale);
      _quantity.text = Bn.localiseDigits('1', locale);
    } else if (_seededLocale != locale) {
      followLocaleDigits([_fx, _cost, _quantity], locale);
    }
    _seededLocale = locale;
  }

  @override
  void dispose() {
    _fx.dispose();
    _cost.dispose();
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final theme = Theme.of(context);
    final cost = Bn.parse(_cost.text) ?? 0;
    final quantity = Bn.parse(_quantity.text) ?? 0;
    final fx = Bn.parse(_fx.text) ?? 0;

    ComparisonResult? result;
    if (cost > 0 && quantity > 0 && fx > 0) {
      try {
        result = const CountryBenchmarkCalculator().compare(
          item: _item,
          projectCostBdt: cost,
          quantity: quantity,
          usdToBdt: fx,
          fxAsOf: widget.pack.fxAsOf,
        );
      } on CalcException {
        result = null;
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        SectionCard(
          title: context.t(S.readThisFirst),
          icon: Icons.report_gmailerrorred_outlined,
          child: Text(
            locale.isBangla
                ? 'এই পর্দা এক দেশের খরচের সঙ্গে আরেক দেশের খরচ মেলায়। '
                    'সংখ্যাগুলো এক রকম জিনিস বোঝায় না — জমি, মাটি, সেতু, '
                    'স্পেসিফিকেশন আর সাল সবই আলাদা। ফলাফলের সঙ্গের সতর্কবার্তাগুলো '
                    'না পড়ে কোনো সিদ্ধান্তে যাবেন না।'
                : 'This screen lines one country\'s cost up against another\'s. '
                    'The figures do not mean the same thing — land, ground '
                    'conditions, structures, specification and year all differ. '
                    'Do not act on the result without reading the warnings that '
                    'come with it.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _item.id,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: locale.isBangla ? 'কীসের তুলনা' : 'What to compare',
          ),
          items: [
            for (final i in widget.pack.items)
              DropdownMenuItem(value: i.id, child: Text(i.title.of(locale)))
          ],
          onChanged: (v) =>
              setState(() => _item = widget.pack.itemById(v!)!),
        ),
        const SizedBox(height: 16),
        _numberField(
          context,
          _cost,
          locale.isBangla ? 'প্রকল্পের মোট খরচ' : 'Total project cost',
          locale.isBangla ? '৳' : 'Tk',
          money: true,
        ),
        const SizedBox(height: 12),
        _numberField(
          context,
          _quantity,
          locale.isBangla ? 'পরিমাণ (কিলোমিটার)' : 'Quantity (km)',
          null,
        ),
        const SizedBox(height: 12),
        _numberField(
          context,
          _fx,
          '${context.t(S.exchangeRate)} '
              '(${Bn.localiseDigits(widget.pack.fxAsOf, locale)})',
          locale.isBangla ? '৳ / \$' : 'Tk / \$',
        ),
        const SizedBox(height: 20),
        _BenchmarkTable(item: _item),
        if (result != null) ...[
          const SizedBox(height: 16),
          _CountryResult(result: result),
        ],
      ],
    );
  }

  Widget _numberField(
    BuildContext context,
    TextEditingController c,
    String label,
    String? suffix, {
    bool money = false,
  }) =>
      TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9০-৯.,\s]')),
          if (money) GroupedNumberFormatter(context.locale),
        ],
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(labelText: label, suffixText: suffix),
      );
}

class _BenchmarkTable extends StatelessWidget {
  const _BenchmarkTable({required this.item});

  final BenchmarkItem item;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final theme = Theme.of(context);
    return SectionCard(
      title: item.title.of(locale),
      icon: Icons.public_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final b in item.benchmarks)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          b.label == null
                              ? b.country.of(locale)
                              : '${b.country.of(locale)} · '
                                  '${b.label!.of(locale)}',
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      Text(
                        b.isRange
                            ? _usdMillions(b.lowUsd, locale, to: b.highUsd)
                            : _usdMillions(b.midUsd, locale),
                        style: theme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    b.year == null
                        ? (locale.isBangla
                            ? 'সাল নিশ্চিত নয়'
                            : 'Year not confirmed')
                        : '${b.year}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(b.comparability.of(locale),
                      style: theme.textTheme.bodySmall),
                  ReviewBadge(status: b.status),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CountryResult extends StatelessWidget {
  const _CountryResult({required this.result});

  final ComparisonResult result;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: context.t(S.result),
          icon: Icons.compare_arrows,
          child: Column(
            children: [
              ValueRow(
                label: locale.isBangla ? 'প্রতি এককে খরচ' : 'Cost per unit',
                value: Bn.takaWords(result.perUnitBdt, locale: locale),
                emphasis: true,
              ),
              ValueRow(
                label: locale.isBangla ? 'ডলারে' : 'In dollars',
                value: _usdMillions(result.perUnitUsd, locale, decimals: 2),
                emphasis: true,
              ),
              const Divider(height: 24),
              for (final c in result.comparisons)
                ValueRow(
                  label: c.benchmark.label == null
                      ? c.benchmark.country.of(locale)
                      : '${c.benchmark.country.of(locale)} · '
                          '${c.benchmark.label!.of(locale)}',
                  value: locale.isBangla
                      ? '${Bn.number(c.multipleLow, decimals: 1, locale: locale)}'
                          '–${Bn.number(c.multipleHigh, decimals: 1, locale: locale)} গুণ'
                      : '${Bn.number(c.multipleLow, decimals: 1, locale: locale)}'
                          '–${Bn.number(c.multipleHigh, decimals: 1, locale: locale)}×',
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: locale.isBangla
              ? 'এই তুলনা পড়ার আগে যা জানা দরকার'
              : 'Before you read anything into this',
          icon: Icons.warning_amber_rounded,
          accent: theme.colorScheme.error,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final c in result.caveats)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(
                        child: Text(c.of(locale),
                            style: theme.textTheme.bodyMedium),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
