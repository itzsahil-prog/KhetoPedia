import 'package:dio/dio.dart';

import '../../../core/network/network.dart';
import '../domain/field.dart';

/// Fields repository for CRUD operations.
class FieldsRepository {
  const FieldsRepository(this._dio);

  final Dio _dio;

  /// Get all fields.
  Future<List<Field>> getFields() async {
    try {
      final resp = await _dio.get<List<dynamic>>('/farms/fields/all');
      return (resp.data!).map((f) => Field.fromJson(f as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw DioClient.mapException(e);
    }
  }

  /// Get single field.
  Future<Field> getField(String fieldId) async {
    try {
      final resp = await _dio.get<Map<String, dynamic>>('/farms/fields/$fieldId');
      return Field.fromJson(resp.data!);
    } on DioException catch (e) {
      throw DioClient.mapException(e);
    }
  }

  /// Create field.
  Future<Field> createField(Map<String, dynamic> data) async {
    try {
      final resp = await _dio.post<Map<String, dynamic>>('/farms/fields', data: data);
      return Field.fromJson(resp.data!);
    } on DioException catch (e) {
      throw DioClient.mapException(e);
    }
  }

  /// Update field.
  Future<Field> updateField(String fieldId, Map<String, dynamic> data) async {
    try {
      final resp = await _dio.put<Map<String, dynamic>>('/farms/fields/$fieldId', data: data);
      return Field.fromJson(resp.data!);
    } on DioException catch (e) {
      throw DioClient.mapException(e);
    }
  }

  /// Delete field.
  Future<void> deleteField(String fieldId) async {
    try {
      await _dio.delete<void>('/farms/fields/$fieldId');
    } on DioException catch (e) {
      throw DioClient.mapException(e);
    }
  }
}
