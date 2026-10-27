import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/network/network.dart';
import '../domain/crop_scan.dart';

/// Crop scanner repository.
class CropScannerRepository {
  const CropScannerRepository(this._dio);

  final Dio _dio;

  /// Analyze crop image.
  Future<CropScan> analyzeCrop({
    required Uint8List imageBytes,
    required String filename,
    String? fieldId,
    String? cropHint,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(imageBytes, filename: filename),
        if (fieldId != null) 'field_id': fieldId,
        if (cropHint != null) 'crop_hint': cropHint,
      });

      final resp = await _dio.post<Map<String, dynamic>>(
        '/crop-scans',
        data: formData,
      );
      return CropScan.fromJson(resp.data!);
    } on DioException catch (e) {
      throw DioClient.mapException(e);
    }
  }

  /// Get crop scan history.
  Future<List<CropScan>> getHistory({
    String? fieldId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final resp = await _dio.get<Map<String, dynamic>>(
        '/crop-scans',
        queryParameters: {
          if (fieldId != null) 'field_id': fieldId,
          'page': page,
          'page_size': pageSize,
        },
      );
      final scans = resp.data!['scans'] as List;
      return scans.map((s) => CropScan.fromJson(s as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw DioClient.mapException(e);
    }
  }

  /// Get specific scan by ID.
  Future<CropScan> getScan(String scanId) async {
    try {
      final resp = await _dio.get<Map<String, dynamic>>('/crop-scans/$scanId');
      return CropScan.fromJson(resp.data!);
    } on DioException catch (e) {
      throw DioClient.mapException(e);
    }
  }
}
