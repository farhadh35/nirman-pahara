import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../core/i18n/strings.dart';
import 'calc_spec.dart';
import 'calculator_screen.dart';

class CalculatorsScreen extends StatelessWidget {
  const CalculatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.t(S.calculate))),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: CalcSpec.all.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final spec = CalcSpec.all[i];
          return Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              title: Text(context.t(spec.title),
                  style: theme.textTheme.titleMedium),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(context.t(spec.subtitle)),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CalculatorScreen(spec: spec),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
