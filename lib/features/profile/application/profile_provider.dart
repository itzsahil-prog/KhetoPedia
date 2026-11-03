import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network.dart';
import '../data/profile_repository.dart';
import '../domain/profile.dart';

/// Provides [ProfileRepository] instance.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  return ProfileRepository(dio);
});

/// Profile state notifier.
class ProfileNotifier extends AsyncNotifier<Profile> {
  @override
  Future<Profile> build() async {
    return _repo.getProfile();
  }

  ProfileRepository get _repo => ref.read(profileRepositoryProvider);

  /// Update profile information.
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? location,
    String? preferredLocale,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final request = ProfileUpdateRequest(
        name: name,
        phone: phone,
        location: location,
        preferredLocale: preferredLocale,
      );
      return _repo.updateProfile(request);
    });
  }

  /// Change password.
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      await _repo.changePassword(request);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Refresh profile data.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getProfile());
  }
}

/// Global profile provider.
final profileProvider = AsyncNotifierProvider<ProfileNotifier, Profile>(
  ProfileNotifier.new,
);
