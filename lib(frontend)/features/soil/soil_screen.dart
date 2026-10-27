import 'package:flutter/material.dart';
import '../../shared/widgets/widgets.dart';
import '../../core/localization/localization.dart';

/// Soil feature — shell placeholder.
class SoilScreen extends StatelessWidget {
  const SoilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: EmptyState(
        icon: Icons.science_outlined,
        title: l.tabSoil,
        message: 'Soil toxicity lab coming soon.',
      ),
    );
  }
}
