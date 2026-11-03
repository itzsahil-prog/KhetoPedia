import 'package:flutter/foundation.dart';

/// A single numeric KPI shown in the dashboard stats row.
///
/// All values are strings as returned by the API — the UI never invents them.
@immutable
final class QuickStat {
  const QuickStat({
    required this.key,
    required this.label,
    required this.value,
    this.unit,
    this.trend,
  });

  /// Machine-readable key, e.g. `"total_fields"`, `"avg_health_score"`.
  final String  key;
  /// Human-readable label from the API (already localised by the server
  /// if the server supports it, otherwise localised on the client via key).
  final String  label;
  /// Formatted value string, e.g. `"3"`, `"82"`, `"4.2 ha"`.
  final String  value;
  /// Optional unit string, e.g. `"acres"`, `"%"`.
  final String? unit;
  /// Optional trend direction: `"up"`, `"down"`, `"stable"` — or null.
  final String? trend;

  factory QuickStat.fromJson(Map<String, dynamic> json) {
    return QuickStat(
      key:   json['key']   as String,
      label: json['label'] as String,
      value: json['value'].toString(),
      unit:  json['unit']  as String?,
      trend: json['trend'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuickStat &&
          other.key   == key &&
          other.value == value;

  @override
  int get hashCode => Object.hash(key, value);

  @override
  String toString() => 'QuickStat(key: $key, value: $value $unit)';
}
