import 'package:flutter/foundation.dart';

/// Compact field card shown in the dashboard's "Recent Fields" list.
/// Full field detail lives in the Fields feature.
@immutable
final class FieldSummary {
  const FieldSummary({
    required this.id,
    required this.name,
    required this.cropName,
    required this.areaHectares,
    this.healthScore,
    this.status,
    this.lastScannedAt,
    this.thumbnailUrl,
  });

  final String   id;
  final String   name;
  final String   cropName;
  /// Area in hectares as reported by the API.
  final double   areaHectares;
  /// 0–100 score from the last AI scan; null if never scanned.
  final int?     healthScore;
  /// Status token from the API, e.g. `"healthy"`, `"at_risk"`, `"critical"`.
  final String?  status;
  final DateTime? lastScannedAt;
  final String?  thumbnailUrl;

  factory FieldSummary.fromJson(Map<String, dynamic> json) {
    return FieldSummary(
      id:           json['id']           as String,
      name:         json['name']         as String,
      cropName:     json['crop_name']    as String,
      areaHectares: (json['area_hectares'] as num).toDouble(),
      healthScore:  json['health_score'] as int?,
      status:       json['status']       as String?,
      lastScannedAt: _parseDate(json['last_scanned_at']),
      thumbnailUrl:  json['thumbnail_url'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is FieldSummary && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'FieldSummary(id: $id, name: $name, crop: $cropName)';

  static DateTime? _parseDate(dynamic v) =>
      v is String ? DateTime.tryParse(v)?.toUtc() : null;
}
