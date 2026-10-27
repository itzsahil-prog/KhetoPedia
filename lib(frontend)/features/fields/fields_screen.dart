import 'package:flutter/material.dart';
import '../../shared/widgets/widgets.dart';
import '../../core/localization/localization.dart';

/// Fields feature — shell placeholder.
class FieldsScreen extends StatelessWidget {
  const FieldsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: EmptyState(
        icon: Icons.landscape_outlined,
        title: l.tabFields,
        message: 'Field management coming soon.',
      ),
    );
  }
}
