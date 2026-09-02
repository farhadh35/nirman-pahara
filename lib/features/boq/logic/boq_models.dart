/// One priced line of a Bill of Quantities or a measurement statement.
///
/// Modelled on the statements actually issued by Bangladeshi procuring
/// entities, which carry both the scheduled quantity and the quantity measured
/// on the ground, so the two can be set against each other.
class BoqLine {
  const BoqLine({
    required this.serial,
    required this.description,
    this.unit,
    this.scheduleQuantity,
    this.measuredQuantity,
    this.rate,
    this.scheduleAmount,
    this.measuredAmount,
    this.columnsTrusted = true,
  });

  /// Item number as printed, e.g. '1.05'. Sub-items repeat their parent's.
  final String serial;

  final String description;
  final String? unit;

  final double? scheduleQuantity;
  final double? measuredQuantity;
  final double? rate;
  final double? scheduleAmount;
  final double? measuredAmount;

  /// False when the row printed fewer figures than the sheet's full column
  /// set, so which figure is the quantity and which is the rate cannot be told
  /// apart. Checks that depend on column position skip these rows rather than
  /// report a finding that would not survive being questioned.
  final bool columnsTrusted;

  bool get hasSchedule => (scheduleQuantity ?? 0) > 0;
  bool get hasMeasured => (measuredQuantity ?? 0) > 0;

  /// Measured beyond scheduled, as a percentage of the scheduled quantity.
  double? get overrunPercent {
    final s = scheduleQuantity;
    final m = measuredQuantity;
    if (s == null || m == null || s <= 0) return null;
    return (m - s) / s * 100;
  }

  /// What the scheduled amount should be if quantity times rate is honoured.
  double? get impliedScheduleAmount {
    final q = scheduleQuantity;
    final r = rate;
    if (q == null || r == null) return null;
    return q * r;
  }

  double? get impliedMeasuredAmount {
    final q = measuredQuantity;
    final r = rate;
    if (q == null || r == null) return null;
    return q * r;
  }
}

/// A parsed statement, with whatever totals it printed for itself.
class BoqDocument {
  const BoqDocument({
    required this.title,
    required this.lines,
    this.statedScheduleTotal,
    this.statedMeasuredTotal,
    this.totalRowCount = 0,
  });

  final String title;
  final List<BoqLine> lines;

  /// The totals the document prints, which are not always the sum of its own
  /// rows — which is itself worth knowing.
  final double? statedScheduleTotal;
  final double? statedMeasuredTotal;

  /// How many total rows the document printed. These statements often carry a
  /// total per section and then a grand total; comparing one section's total
  /// against every line in the document would manufacture a discrepancy.
  final int totalRowCount;

  double get summedScheduleAmount => lines.fold(
      0, (t, l) => t + (l.scheduleAmount ?? 0));

  double get summedMeasuredAmount => lines.fold(
      0, (t, l) => t + (l.measuredAmount ?? 0));
}
