import 'package:flutter/foundation.dart';

/// Severity levels a farm alert can carry.
enum AlertSeverity { info, warning, critical }

AlertSeverity _parseSeverity(String? raw) => switch (raw?.toLowerCase()) {
  'critical' => AlertSeverity.critical,
  'warning'  => AlertSeverity.warning,
  _          => AlertSeverity.info,
};

/// A single farm alert returned by `/dashboard/summary` or `/dashboard/alerts`.
@immutable
final class AlertItem {
  const AlertItem({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    this.fieldId,
    this.fieldName,
    this.createdAt,
    this.isRead = false,
  });

  final String        id;
  final String        title;
  final String        description;
  final AlertSeverity severity;
  final String?       fieldId;
  final String?       fieldName;
  final DateTime?     createdAt;
  final bool          isRead;

  factory AlertItem.fromJson(Map<String, dynamic> json) {
    return AlertItem(
      id:          json['id']          as String,
      title:       json['title']       as String,
      description: json['description'] as String,
      severity:    _parseSeverity(json['severity'] as String?),
      fieldId:     json['field_id']    as String?,
      fieldName:   json['field_name']  as String?,
      createdAt:   _parseDate(json['created_at']),
      isRead:      (json['is_read'] as bool?) ?? false,
    );
  }

  AlertItem copyWith({bool? isRead}) => AlertItem(
    id:          id,
    title:       title,
    description: description,
    severity:    severity,
    fieldId:     fieldId,
    fieldName:   fieldName,
    createdAt:   createdAt,
    isRead:      isRead ?? this.isRead,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is AlertItem && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AlertItem(id: $id, severity: $severity, title: $title)';

  static DateTime? _parseDate(dynamic v) =>
      v is String ? DateTime.tryParse(v)?.toUtc() : null;
}
