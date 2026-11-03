import 'package:dio/dio.dart';

import '../../../core/network/network.dart';
import '../domain/profile.dart';

/// Profile update request DTO.
final class ProfileUpdateRequest {
  const ProfileUpdateRequest({
    this.name,
    this.phone,
    this.location,
    this.preferredLocale,
  });

  final String? name;
  final String? phone;
  final String? location;
  final String? preferredLocale;

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (phone != null) 'phone': phone,
    if (location != null) 'location': location,
    if (preferredLocale != null) 'preferred_locale': preferredLocale,
  };
}

/// Password change request DTO.
final class ChangePasswordRequest {
  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;

  Map<String, dynamic> toJson() => {
    'current_password': currentPassword,
    'new_password': newPassword,
  };
}

/// Profile repository for user profile operations.
class ProfileRepository {
  const ProfileRepository(this._dio);

  final Dio _dio;

  /// Fetch authenticated user's profile.
  Future<Profile> getProfile() async {
    try {
      final resp = await _dio.get<Map<String, dynamic>>('/users/profile');
      return Profile.fromJson(resp.data!);
    } on DioException catch (e) {
      throw DioClient.mapException(e);
    }
  }

  /// Update user profile.
  Future<Profile> updateProfile(ProfileUpdateRequest request) async {
    try {
      final resp = await _dio.put<Map<String, dynamic>>(
        '/users/profile',
        data: request.toJson(),
      );
      return Profile.fromJson(resp.data!);
    } on DioException catch (e) {
      throw DioClient.mapException(e);
    }
  }

  /// Change user password.
  Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      await _dio.put<void>('/users/change-password', data: request.toJson());
    } on DioException catch (e) {
      throw DioClient.mapException(e);
    }
  }
}
