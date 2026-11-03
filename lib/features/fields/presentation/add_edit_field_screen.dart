import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization.dart';
import '../../../shared/widgets/widgets.dart';
import '../application/fields_provider.dart';
import '../domain/field.dart';

/// Screen for adding or editing a field.
class AddEditFieldScreen extends ConsumerStatefulWidget {
  const AddEditFieldScreen({super.key, this.field});

  final Field? field;

  @override
  ConsumerState<AddEditFieldScreen> createState() => _AddEditFieldScreenState();
}

class _AddEditFieldScreenState extends ConsumerState<AddEditFieldScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _cropController;
  late final TextEditingController _areaController;
  bool _isLoading = false;

  bool get _isEditing => widget.field != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.field?.name ?? '');
    _cropController = TextEditingController(text: widget.field?.crop ?? '');
    _areaController = TextEditingController(
      text: widget.field?.area.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cropController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(fieldsNotifierProvider.notifier);
      
      if (_isEditing) {
        await notifier.updateField(
          widget.field!.id,
          name: _nameController.text.trim(),
          crop: _cropController.text.trim(),
          area: double.parse(_areaController.text.trim()),
        );
      } else {
        await notifier.createField(
          name: _nameController.text.trim(),
          crop: _cropController.text.trim(),
          area: double.parse(_areaController.text.trim()),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).fieldsSaved)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).errorGeneric)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l.fieldsEdit : l.fieldsAdd),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppTextField(
              controller: _nameController,
              label: l.fieldsName,
              prefixIcon: Icons.landscape_outlined,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l.authFieldRequired : null,
              semanticLabel: l.fieldsName,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _cropController,
              label: l.fieldsCrop,
              prefixIcon: Icons.grass_outlined,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l.authFieldRequired : null,
              semanticLabel: l.fieldsCrop,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _areaController,
              label: l.fieldsArea,
              prefixIcon: Icons.straighten_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l.authFieldRequired;
                final num = double.tryParse(v);
                if (num == null || num <= 0) return 'Enter a valid area';
                return null;
              },
              semanticLabel: l.fieldsArea,
            ),
            const SizedBox(height: 32),
            AppButton(
              onPressed: _isLoading ? null : _save,
              label: _isLoading ? l.loading : l.save,
              icon: Icons.check,
            ),
          ],
        ),
      ),
    );
  }
}
