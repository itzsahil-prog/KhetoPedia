import 'package:flutter/material.dart';
import '../../shared/widgets/widgets.dart';
import '../../core/localization/localization.dart';

/// Scan feature — shell placeholder.
class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: EmptyState(
        icon: Icons.center_focus_strong_outlined,
        title: l.tabScan,
        message: 'Crop scanner coming soon.',
      ),
    );
  }
}
