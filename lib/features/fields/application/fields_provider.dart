import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network.dart';
import '../data/fields_repository.dart';
import '../domain/field.dart';

/// Provides [FieldsRepository] instance.
final fieldsRepositoryProvider = Provider<FieldsRepository>((ref) {
  final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  return FieldsRepository(dio);
});

/// Fields list provider.
final fieldsListProvider = FutureProvider.autoDispose<List<Field>>((ref) async {
  final repo = ref.watch(fieldsRepositoryProvider);
  return repo.getFields();
});

/// Single field provider.
final fieldProvider = FutureProvider.autoDispose.family<Field, String>((ref, fieldId) async {
  final repo = ref.watch(fieldsRepositoryProvider);
  return repo.getField(fieldId);
});

/// Fields notifier for mutations.
class FieldsNotifier extends Notifier<void> {
  @override
  void build() {}

  FieldsRepository get _repo => ref.read(fieldsRepositoryProvider);

  Future<Field> createField({
    required String name,
    required String crop,
    required double area,
    String? farmId,
  }) async {
    final result = await _repo.createField({
      'name': name,
      'crop': crop,
      'area': area,
      if (farmId != null) 'farm_id': farmId,
    });
    ref.invalidate(fieldsListProvider);
    return result;
  }

  Future<Field> updateField(
    String fieldId, {
    String? name,
    String? crop,
    double? area,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (crop != null) data['crop'] = crop;
    if (area != null) data['area'] = area;
    
    final result = await _repo.updateField(fieldId, data);
    ref.invalidate(fieldsListProvider);
    ref.invalidate(fieldProvider(fieldId));
    return result;
  }

  Future<void> deleteField(String fieldId) async {
    await _repo.deleteField(fieldId);
    ref.invalidate(fieldsListProvider);
  }
}

final fieldsNotifierProvider = NotifierProvider<FieldsNotifier, void>(FieldsNotifier.new);
