import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network.dart';
import '../data/crop_scanner_repository.dart';
import '../domain/crop_scan.dart';

/// Provides [CropScannerRepository] instance.
final cropScannerRepositoryProvider = Provider<CropScannerRepository>((ref) {
  final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  return CropScannerRepository(dio);
});

/// Crop scan history provider.
final cropScanHistoryProvider = FutureProvider.autoDispose<List<CropScan>>((ref) async {
  final repo = ref.watch(cropScannerRepositoryProvider);
  return repo.getHistory();
});

/// Single crop scan provider.
final cropScanProvider = FutureProvider.autoDispose.family<CropScan, String>((ref, scanId) async {
  final repo = ref.watch(cropScannerRepositoryProvider);
  return repo.getScan(scanId);
});

/// Crop scanner notifier for analysis operations.
class CropScannerNotifier extends AsyncNotifier<CropScan?> {
  @override
  Future<CropScan?> build() async => null;

  CropScannerRepository get _repo => ref.read(cropScannerRepositoryProvider);

  /// Analyze a crop image.
  Future<CropScan> analyzeCrop({
    required Uint8List imageBytes,
    required String filename,
    String? fieldId,
    String? cropHint,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _repo.analyzeCrop(
        imageBytes: imageBytes,
        filename: filename,
        fieldId: fieldId,
        cropHint: cropHint,
      );
      state = AsyncValue.data(result);
      
      // Invalidate history to refresh it
      ref.invalidate(cropScanHistoryProvider);
      
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Clear current scan result.
  void clear() {
    state = const AsyncValue.data(null);
  }
}

/// Global crop scanner provider.
final cropScannerProvider = AsyncNotifierProvider<CropScannerNotifier, CropScan?>(
  CropScannerNotifier.new,
);
