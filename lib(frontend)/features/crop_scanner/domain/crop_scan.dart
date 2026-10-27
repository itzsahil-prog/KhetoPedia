/// Crop scan result domain model.
final class CropScan {
  const CropScan({
    required this.id,
    required this.imageUrl,
    required this.cropType,
    required this.confidence,
    this.disease,
    this.diseaseConfidence,
    this.recommendations,
    this.fieldId,
    this.createdAt,
  });

  final String    id;
  final String    imageUrl;
  final String    cropType;
  final double    confidence;      // 0.0 - 1.0
  final String?   disease;
  final double?   diseaseConfidence;
  final List<String>? recommendations;
  final String?   fieldId;
  final DateTime? createdAt;

  bool get isHealthy => disease == null || disease!.toLowerCase() == 'healthy';

  factory CropScan.fromJson(Map<String, dynamic> json) {
    return CropScan(
      id:                 json['id'] as String,
      imageUrl:           json['image_url'] as String,
      cropType:           json['crop_type'] as String,
      confidence:         (json['confidence'] as num).toDouble(),
      disease:            json['disease'] as String?,
      diseaseConfidence:  json['disease_confidence'] != null
          ? (json['disease_confidence'] as num).toDouble()
          : null,
      recommendations:    json['recommendations'] != null
          ? List<String>.from(json['recommendations'] as List)
          : null,
      fieldId:            json['field_id'] as String?,
      createdAt:          json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':           id,
    'image_url':    imageUrl,
    'crop_type':    cropType,
    'confidence':   confidence,
    if (disease != null) 'disease': disease,
    if (diseaseConfidence != null) 'disease_confidence': diseaseConfidence,
    if (recommendations != null) 'recommendations': recommendations,
    if (fieldId != null) 'field_id': fieldId,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };
}
