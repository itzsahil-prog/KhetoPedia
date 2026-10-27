/// User profile domain model.
final class Profile {
  const Profile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.location,
    this.preferredLocale,
    this.createdAt,
    this.totalFields,
    this.totalArea,
  });

  final String    id;
  final String    name;
  final String    email;
  final String?   phone;
  final String?   location;
  final String?   preferredLocale;
  final DateTime? createdAt;
  final int?      totalFields;
  final double?   totalArea;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id:              json['id'] as String,
      name:            json['name'] as String,
      email:           json['email'] as String,
      phone:           json['phone'] as String?,
      location:        json['location'] as String?,
      preferredLocale: json['preferred_locale'] as String?,
      createdAt:       json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      totalFields:     json['total_fields'] as int?,
      totalArea:       json['total_area'] != null
          ? (json['total_area'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':               id,
    'name':             name,
    'email':            email,
    if (phone != null)  'phone': phone,
    if (location != null) 'location': location,
    if (preferredLocale != null) 'preferred_locale': preferredLocale,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (totalFields != null) 'total_fields': totalFields,
    if (totalArea != null) 'total_area': totalArea,
  };
}
