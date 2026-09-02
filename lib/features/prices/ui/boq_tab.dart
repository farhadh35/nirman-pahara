import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_scope.dart';
import '../../../app/widgets/common.dart';
import '../../../app/widgets/locale_fields.dart';
import '../../../core/i18n/app_locale.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/util/bn.dart';
import '../../../core/util/grouped_number_formatter.dart';
import '../../calculators/logic/calc_result.dart';
import '../logic/boq_compare.dart';
import '../logic/pwd_rate_table.dart';

/// Compare a rate written in a Bill of Quantities against the published PWD
/// schedule.
///
/// The rates here are the real ones, parsed out of the official PDF, so the
/// screen leads with which edition they came from — a rate quoted from the
/// wrong revision is worse than no rate at all.
class BoqTab extends StatefulWidget {
  const BoqTab({super.key, required this.tables});

  /// The published volumes, civil first.
  ///
  /// PWD prints civil and electro-mechanical rates as separate books with their
  /// own item numbering, so they are chosen between rather than merged: an
  /// electrical bill checked against the civil book finds nothing and looks
  /// clean, which is the worst outcome this screen can produce.
  final List<PwdRateTable> tables;

  @override
  State<BoqTab> createState() => _BoqTabState();
}

class _BoqTabState extends State<BoqTab> {
  final _search = TextEditingController();
  final _boqRate = TextEditingController();
  final _quantity = TextEditingController();
  AppLocale? _seededLocale;
  PwdRateItem? _item;
  int _region = 0;
  int _volume = 0;

  PwdRateTable get _table => widget.tables[_volume];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // These boxes start empty, so there is no seed to convert — but a reader
    // who typed Bangla digits and then switched to English should not be left
    // looking at them.
    final locale = context.locale;
    if (_seededLocale != null && _seededLocale != locale) {
      followLocaleDigits([_boqRate, _quantity], locale);
    }
    _seededLocale = locale;
  }

  @override
  void dispose() {
    _search.dispose();
    _boqRate.dispose();
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final bn = locale.isBangla;
    final theme = Theme.of(context);
    final table = _table;

    final boq = Bn.parse(_boqRate.text) ?? 0;
    final quantity = Bn.parse(_quantity.text) ?? 0;
    final item = _item;

    CalcResult? result;
    final scheduleRate = item?.rateFor(_region);
    if (item != null && scheduleRate != null && boq > 0 && quantity > 0) {
      try {
        result = const BoqComparison().compare(
          itemLabel: L10nText(
            '${item.code} — ${item.description}',
            '${item.code} — ${item.description}',
          ),
          scheduleLabel: table.schedule,
          unit: item.unit,
          scheduleRate: scheduleRate,
          boqRate: boq,
          quantity: quantity,
          locale: locale,
        );
      } on CalcException {
        result = null;
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        if (widget.tables.length > 1) ...[
          Text(
            bn ? 'কোন তফসিল' : 'Which schedule',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (var i = 0; i < widget.tables.length; i++)
                ChoiceChip(
                  label: Text(widget.tables[i].volume?.of(locale) ??
                      (bn ? 'পুর্ত কাজ' : 'Civil works')),
                  selected: _volume == i,
                  onSelected: (_) => setState(() {
                    _volume = i;
                    _item = null;
                    _search.clear();
                  }),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        _EditionCard(table: table),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          initialValue: _region,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: bn ? 'অঞ্চল' : 'Region',
            helperText: bn
                ? 'শিডিউলে প্রতিটি আইটেমের রেট অঞ্চলভেদে আলাদা'
                : 'The schedule prices every item differently by region',
          ),
          items: [
            for (var i = 0; i < table.regions.length; i++)
              DropdownMenuItem(
                value: i,
                child: Text(table.regions[i].name.of(locale)),
              )
          ],
          onChanged: (v) => setState(() => _region = v ?? 0),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            labelText: bn ? 'আইটেম খুঁজুন' : 'Find an item',
            helperText: bn
                ? 'আইটেম নম্বর বা কাজের বর্ণনা দিয়ে খুঁজুন — যেমন 07.1.3'
                : 'Search by item number or description — for example 07.1.3',
            helperMaxLines: 2,
          ),
        ),
        const SizedBox(height: 12),
        if (item == null)
          _Results(
            items: table.search(_search.text),
            region: _region,
            onPick: (i) => setState(() {
              _item = i;
              _search.text = i.code;
            }),
          )
        else ...[
          _PickedItem(
            item: item,
            region: _region,
            regionName: table.regions[_region].name,
            onClear: () => setState(() {
              _item = null;
              _search.clear();
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _boqRate,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9০-৯.,\s]')),
              GroupedNumberFormatter(locale),
            ],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: bn ? 'BoQ-তে লেখা রেট' : 'Rate written in the BoQ',
              helperText:
                  bn ? 'অনুমিত হিসাব বা BoQ থেকে' : 'From the estimate or BoQ',
              suffixText: bn ? '৳' : 'Tk',
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
              labelText: bn
                  ? 'পরিমাণ (${item.unit.of(locale)})'
                  : 'Quantity (${item.unit.of(locale)})',
              helperText: bn
                  ? 'BoQ-তে যত পরিমাণ ধরা আছে'
                  : 'The quantity the BoQ carries',
            ),
          ),
          const SizedBox(height: 20),
          if (result != null) _Result(result: result),
          const SizedBox(height: 16),
          if (table.profitPercent != null && table.overheadPercent != null)
          Text(
            bn
                ? 'মনে রাখবেন: শিডিউলের রেটে ঠিকাদারের লাভ '
                    '${Bn.number(table.profitPercent!, decimals: 0, locale: locale)}% '
                    'ও ওভারহেড '
                    '${Bn.number(table.overheadPercent!, decimals: 1, locale: locale)}% '
                    'আগে থেকেই ধরা আছে।'
                : 'Note: the schedule rate already includes '
                    '${table.profitPercent!.toStringAsFixed(0)}% contractor '
                    'profit and ${table.overheadPercent!.toStringAsFixed(1)}% '
                    'overhead.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// Which edition these rates came from, stated before any number is shown.
class _EditionCard extends StatelessWidget {
  const _EditionCard({required this.table});

  final PwdRateTable table;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final bn = locale.isBangla;
    final theme = Theme.of(context);
    return SectionCard(
      title: bn ? 'কোন শিডিউল' : 'Which schedule',
      icon: Icons.menu_book_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(table.schedule.of(locale),
              style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            bn
                ? 'কার্যকর ${Bn.localiseDigits(table.effective, locale)} · '
                    '${Bn.number(table.items.length.toDouble(), decimals: 0, locale: locale)} টি আইটেম'
                : 'Effective ${table.effective} · '
                    '${table.items.length} items',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            bn
                ? 'রেটগুলো সরকারি পিডিএফ থেকে নেওয়া। RHD ও LGED-র শিডিউল আলাদা — '
                    'ঐ কাজের জন্য এই রেট প্রযোজ্য নয়।'
                : 'These rates were taken from the official PDF. RHD and LGED '
                    'keep separate schedules, and these rates do not apply to '
                    'their works.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => copyToClipboard(context, table.sourceUrl),
              icon: const Icon(Icons.link, size: 18),
              label: Text(context.t(S.source)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({
    required this.items,
    required this.region,
    required this.onPick,
  });

  final List<PwdRateItem> items;
  final int region;
  final ValueChanged<PwdRateItem> onPick;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return CautionBox(
        icon: Icons.search_off,
        text: locale.isBangla
            ? 'এই নামে কোনো আইটেম পাওয়া যায়নি। অন্য শব্দ বা আইটেম নম্বর দিয়ে দেখুন।'
            : 'No item found. Try another word, or the item number.',
      );
    }
    return Column(
      children: [
        for (final i in items.take(25))
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(i.code, style: theme.textTheme.titleSmall),
              subtitle: Text(i.description, maxLines: 3,
                  overflow: TextOverflow.ellipsis),
              trailing: Text(
                i.rateFor(region) == null
                    ? '—'
                    : Bn.taka(i.rateFor(region)!, locale: locale),
                style: theme.textTheme.titleSmall,
              ),
              onTap: () => onPick(i),
            ),
          ),
      ],
    );
  }
}

class _PickedItem extends StatelessWidget {
  const _PickedItem({
    required this.item,
    required this.region,
    required this.regionName,
    required this.onClear,
  });

  final PwdRateItem item;
  final int region;
  final L10nText regionName;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final bn = locale.isBangla;
    final theme = Theme.of(context);
    return SectionCard(
      title: item.code,
      icon: Icons.receipt_long_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(
            '${bn ? 'অধ্যায়' : 'Chapter'} '
            '${Bn.localiseDigits(item.chapter, locale)}'
            ' · ${item.chapterName.of(locale)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Divider(height: 24),
          ValueRow(
            label: '${bn ? 'শিডিউল রেট' : 'Schedule rate'} · '
                '${regionName.of(locale)}',
            value: item.rateFor(region) == null
                ? (bn
                    ? 'প্রকাশিত তফসিলে এই অঞ্চলের রেট স্পষ্ট নয়'
                    : 'the published schedule does not state this zone clearly')
                : '${Bn.taka(item.rateFor(region)!, decimals: 2, locale: locale)}'
                    ' / ${item.unit.of(locale)}',
            emphasis: true,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.close, size: 18),
              label: Text(bn ? 'অন্য আইটেম' : 'Change item'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.result});

  final CalcResult result;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final theme = Theme.of(context);
    final gap = result.valueOf('diff_percent') ?? 0;
    final over = gap > BoqComparison.questionThresholdPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: context.t(S.result),
          icon: Icons.rule_folder_outlined,
          accent: over ? theme.colorScheme.error : null,
          child: Column(
            children: [
              for (final l in result.lines)
                ValueRow(
                  label: l.label.of(locale),
                  value: l.key == 'diff_percent'
                      ? '${Bn.number(l.value, decimals: 1, locale: locale)}%'
                      : Bn.taka(l.value, decimals: l.decimals, locale: locale),
                  emphasis: l.emphasis,
                ),
            ],
          ),
        ),
        if (result.note != null) ...[
          const SizedBox(height: 12),
          CautionBox(text: result.note!.of(locale)),
        ],
        const SizedBox(height: 12),
        SectionCard(
          title: context.t(S.assumptions),
          icon: Icons.functions,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result.formula.of(locale),
                  style: theme.textTheme.bodySmall),
              const SizedBox(height: 10),
              for (final a in result.assumptions)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('• ${a.of(locale)}',
                      style: theme.textTheme.bodySmall),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
