import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization.dart';
import '../../../shared/widgets/widgets.dart';
import '../application/profile_provider.dart';
import '../domain/profile.dart';

/// Screen for editing user profile information.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final Profile profile;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;
  String? _selectedLocale;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
    _locationController = TextEditingController(text: widget.profile.location ?? '');
    _selectedLocale = widget.profile.preferredLocale ?? 'en';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(profileProvider.notifier).updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        preferredLocale: _selectedLocale,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).profileSaved)),
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
        title: Text(l.profileEdit),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppTextField(
              controller: _nameController,
              label: l.profileName,
              prefixIcon: Icons.person_outline,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return l.authFieldRequired;
                }
                return null;
              },
              semanticLabel: l.profileName,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _phoneController,
              label: l.profilePhone,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              semanticLabel: l.profilePhone,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _locationController,
              label: l.profileLocation,
              prefixIcon: Icons.location_on_outlined,
              semanticLabel: l.profileLocation,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedLocale,
              decoration: InputDecoration(
                labelText: l.profilePreferredLocale,
                prefixIcon: const Icon(Icons.language_outlined),
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'en', child: Text(l.languageEnglish)),
                DropdownMenuItem(value: 'hi', child: Text(l.languageHindi)),
              ],
              onChanged: (value) {
                setState(() => _selectedLocale = value);
              },
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
