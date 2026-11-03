/// Domain model for a crop field.
final class Field {
  const Field({
    required this.id,
    required this.name,
    required this.crop,
    required this.area,
    required this.healthScore,
    this.lastScanned,
    this.waterStatus,
    this.soilStatus,
    this.createdAt,
    this.updatedAt,
  });

  final String     id;
  final String     name;
  final String     crop;
  final double     area;          // hectares
  final int        healthScore;   // 0-100
  final DateTime?  lastScanned;
  final String?    waterStatus;   // adequate, low, critical
  final String?    soilStatus;    // healthy, degraded, toxic
  final DateTime?  createdAt;
  final DateTime?  updatedAt;

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id:           json['id'] as String,
      name:         json['name'] as String,
      crop:         json['crop'] as String,
      area:         (json['area'] as num).toDouble(),
      healthScore:  json['health_score'] as int? ?? 75,
      lastScanned:  json['last_scanned'] != null
          ? DateTime.parse(json['last_scanned'] as String)
          : null,
      waterStatus:  json['water_status'] as String?,
      soilStatus:   json['soil_status'] as String?,
      createdAt:    json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt:    json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':           id,
    'name':         name,
    'crop':         crop,
    'area':         area,
    'health_score': healthScore,
    if (lastScanned != null) 'last_scanned': lastScanned!.toIso8601String(),
    if (waterStatus != null) 'water_status': waterStatus,
    if (soilStatus != null)  'soil_status':  soilStatus,
    if (createdAt != null)   'created_at':   createdAt!.toIso8601String(),
    if (updatedAt != null)   'updated_at':   updatedAt!.toIso8601String(),
  };

  Field copyWith({
    String?    name,
    String?    crop,
    double?    area,
    int?       healthScore,
    DateTime?  lastScanned,
    String?    waterStatus,
    String?    soilStatus,
  }) {
    return Field(
      id:          id,
      name:        name ?? this.name,
      crop:        crop ?? this.crop,
      area:        area ?? this.area,
      healthScore: healthScore ?? this.healthScore,
      lastScanned: lastScanned ?? this.lastScanned,
      waterStatus: waterStatus ?? this.waterStatus,
      soilStatus:  soilStatus ?? this.soilStatus,
      createdAt:   createdAt,
      updatedAt:   DateTime.now(),
    );
  }
}
