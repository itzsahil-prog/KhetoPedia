import 'package:flutter/foundation.dart';

import 'alert_item.dart';
import 'field_summary.dart';
import 'quick_stat.dart';

/// The full payload of GET /dashboard/summary.
///
/// Every list may be empty — the UI handles those cases explicitly.
@immutable
final class DashboardSummary {
  const DashboardSummary({
    required this.stats,
    required this.recentFields,
    required this.activeAlerts,
    this.fetchedAt,
  });

  /// Ordered list of KPI tiles — order and content are server-driven.
  final List<QuickStat>    stats;
  /// Up to N recently-accessed/updated fields.
  final List<FieldSummary> recentFields;
  /// Unresolved alerts, sorted by severity desc then createdAt desc.
  final List<AlertItem>    activeAlerts;
  /// When the client received this payload.
  final DateTime?          fetchedAt;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    List<T> _list<T>(String key, T Function(Map<String, dynamic>) fromJson) {
      final raw = json[key];
      if (raw == null) return const [];
      return (raw as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(fromJson)
          .toList(growable: false);
    }

    return DashboardSummary(
      stats:        _list('stats',         QuickStat.fromJson),
      recentFields: _list('recent_fields', FieldSummary.fromJson),
      activeAlerts: _list('active_alerts', AlertItem.fromJson),
      fetchedAt:    DateTime.now().toUtc(),
    );
  }

  bool get hasAlerts      => activeAlerts.isNotEmpty;
  bool get hasFields      => recentFields.isNotEmpty;
  bool get hasStats       => stats.isNotEmpty;
  bool get isEmpty        => !hasAlerts && !hasFields && !hasStats;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DashboardSummary && other.fetchedAt == fetchedAt);

  @override
  int get hashCode => fetchedAt.hashCode;

  @override
  String toString() =>
      'DashboardSummary(stats: ${stats.length}, '
      'fields: ${recentFields.length}, alerts: ${activeAlerts.length})';
}
